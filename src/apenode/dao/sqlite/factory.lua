-- Copyright (C) Mashape, Inc.
local Object = require "classic"
local sqlite3 = require "lsqlite3"

local Faker = require "apenode.tools.faker"
local Migrations = require "apenode.tools.migrations"

local Apis = require "apenode.dao.sqlite.apis"
local Metrics = require "apenode.dao.sqlite.metrics"
local Plugins = require "apenode.dao.sqlite.plugins"
local Accounts = require "apenode.dao.sqlite.accounts"
local Applications = require "apenode.dao.sqlite.applications"
local Jobs = require "apenode.dao.sqlite.jobs"

local SQLiteFactory = Object:extend()

-- Instanciate an SQLite DAO.
-- @param table properties The parsed apenode configuration
-- @param boolean no_prepare Don't prepare statements if true (will fail if tables are not yet migrated)
function SQLiteFactory:new(properties, no_prepare)
  self.type = "sqlite"
  self.faker = Faker(self)
  self.migrations = Migrations(self)

  if properties.memory then
    self._db = sqlite3.open_memory()
    -- In memory needs to be migrated instantly
    self:migrate()
  elseif properties.file_path ~= nil then
    self._db = sqlite3.open(properties.file_path)
  else
    error("Cannot open SQLite database: missing path to file")
  end

  self.apis = Apis(self._db)
  self.metrics = Metrics(self._db)
  self.plugins = Plugins(self._db)
  self.accounts = Accounts(self._db)
  self.applications = Applications(self._db)
  self.jobs = Jobs(self._db)
end

--
-- Migrations
--
function SQLiteFactory:migrate(callback)
  self.migrations:migrate(callback)
end

function SQLiteFactory:rollback(callback)
  self.migrations:rollback(callback)
end

function SQLiteFactory:reset(callback)
  self.migrations:reset(callback)
end

--
-- Seeding
--
function SQLiteFactory:seed(random, number)
  self.faker:seed(random, number)
end

function SQLiteFactory:drop()
  self:execute("DELETE FROM apis")
  self:execute("DELETE FROM metrics")
  self:execute("DELETE FROM plugins")
  self:execute("DELETE FROM accounts")
  self:execute("DELETE FROM applications")
  self:execute("DELETE FROM jobs")
end

--
-- Utilities
--
function SQLiteFactory:prepare()
  self.metrics:prepare()
end

function SQLiteFactory:execute(stmt)
  if self._db:exec(stmt) ~= sqlite3.OK then
    error("SQLite ERROR: "..self._db:errmsg())
  end
end

function SQLiteFactory:close()
  self.apis:finalize()
  self.metrics:finalize()
  self.plugins:finalize()
  self.accounts:finalize()
  self.applications:finalize()
  self.jobs:finalize()

  self._db:close()
end

return SQLiteFactory
