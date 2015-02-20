-- Copyright (C) Mashape, Inc.
local Object = require "classic"
local cassandra = require "cassandra"
local stringy = require "stringy"

local Faker = require "kong.tools.faker"
local migrations = require "kong.tools.migrations"

local Apis = require "kong.dao.cassandra.apis"
local Metrics = require "kong.dao.cassandra.metrics"
local Plugins = require "kong.dao.cassandra.plugins"
local Accounts = require "kong.dao.cassandra.accounts"
local Applications = require "kong.dao.cassandra.applications"

local CassandraFactory = Object:extend()

-- Instanciate a Cassandra DAO.
-- @param properties Cassandra properties
function CassandraFactory:new(properties)
  self.type = "cassandra"
  self._properties = properties

  -- TODO: do not include those on production
  self.faker = Faker(self)
  self._migrations = migrations(self, { keyspace = properties.keyspace })

  self.apis = Apis(properties)
  self.metrics = Metrics(properties)
  self.plugins = Plugins(properties)
  self.accounts = Accounts(properties)
  self.applications = Applications(properties)
end

--
-- Migrations
--

function CassandraFactory:migrate(callback)
  self._migrations:migrate(callback)
end

function CassandraFactory:rollback(callback)
  self._migrations:rollback(callback)
end

function CassandraFactory:reset(callback)
  self._migrations:reset(callback)
end

--
-- Seeding
--

function CassandraFactory:seed(random, number)
  self.faker:seed(random, number)
end

function CassandraFactory:drop()
  self.faker:clear()
  self:execute [[
    TRUNCATE apis;
    TRUNCATE metrics;
    TRUNCATE plugins;
    TRUNCATE accounts;
    TRUNCATE applications;
  ]]
end

--
-- Utilities
--

-- Prepare all statements in collection._queries and put them in collection._statements.
-- Should be called with only a collection and will recursively call itself for nested statements.
--
-- @param collection A collection with a ._queries property
local function prepare(collection, queries, statements)
  if not queries then queries = collection._queries end
  if not statements then statements = collection._statements end

  for stmt_name, query in pairs(queries) do
    if type(query) == "table" and query.query == nil then
      collection._statements[stmt_name] = {}
      prepare(collection, query, collection._statements[stmt_name])
    else
      local q = stringy.strip(query.query)
      q = string.format(q, "")
      local kong_stmt, err = collection:prepare_kong_statement(q, query.params)
      if err then
        error(err)
      end
      statements[stmt_name] = kong_stmt
    end
  end
end

-- Prepare all statements of collections
function CassandraFactory:prepare()
  for _, collection in ipairs({ self.apis,
                                self.metrics,
                                self.plugins,
                                self.accounts,
                                self.applications }) do
    prepare(collection)
  end
end

-- Execute a string of queries separated by ;
-- Useful for huge DDL operations such as migrations
--
-- @param {string} queries Semicolon separated string of queries
-- @param {boolean} no_keyspace Won't set the keyspace if true
function CassandraFactory:execute(queries, no_keyspace)
  local session = cassandra.new()
  session:set_timeout(self._properties.timeout)

  local connected, err = session:connect(self._properties.hosts, self._properties.port)
  if not connected then
    error(err)
  end

  if no_keyspace == nil then
    local ok, err = session:set_keyspace(self._properties.keyspace)
    if not ok then
      error(err)
    end
  end

  -- Cassandra client only support BATCH on DML statements.
  -- We must split commands to execute them individually for migrations and such
  queries = stringy.split(queries, ";")
  for _,query in ipairs(queries) do
    if stringy.strip(query) ~= "" then
      local result, err = session:execute(query)
      if err then
        error("Cassandra execution error: "..err)
      end
    end
  end

  session:close()
end

return CassandraFactory
