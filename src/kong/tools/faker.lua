local Object = require "classic"
local inspect = require "inspect"

math.randomseed(os.time())

-------------
-- PRIVATE --
-------------

-- Throw an error from a string or table object
-- @param {table|string} The error to throw (will be converted to string if is table)
local function throw(err)
  local err_str
  if type(err) == "table" then
    err_str = inspect(err)
  else
    err_str = err
  end

  error(err_str)
end

-- Gets a random elements from an array
-- @param {table} t Array to get an element from
-- @return A random element
local function random_from_table(t)
  if not t then return {} end

  return t[math.random(#t)]
end

-----------
-- Faker --
-----------

local Faker = Object:extend()

function Faker:new(dao_factory)
  self.dao_factory = dao_factory
  self:clear()
end

function Faker:clear()
  self.inserted_entities = {}
end

-- Generate a fake entity
--
-- @param {string} type Type of the entity to generate
-- @return {table} An entity schema
function Faker:fake_entity(type)
  local r = math.random(1, 1000000000)

  if type == "api" then
    return {
      name = "random"..r,
      public_dns = "random"..r..".com",
      target_url = "http://random"..r..".com"
    }
  elseif type == "account" then
    return {
      provider_id = "random_provider_id_"..r
    }
  elseif type == "application" then
    return {
      account_id = random_from_table(self.inserted_entities.account).id,
      public_key = "public_random"..r,
      secret_key = "private_random"..r
    }
  elseif type == "plugin" then
    local type = random_from_table({ "authentication", "ratelimiting" })
    local value = {}
    if type == "authentication" then
      value = { authentication_type = "query", authentication_key_names = { "apikey"..r }}
    else
      value = { period = "minute", limit = r }
    end
    return {
      name = type,
      value = value,
      api_id = random_from_table(self.inserted_entities.api).id,
      application_id = random_from_table(self.inserted_entities.application).id
    }
  else
    throw("Entity of type "..type.." cannot be genereated.")
  end
end

-- Seed the database with a set of hard-coded entities, and optionally random data
--
-- @param {boolean} random If true, will generate random entities
-- @param {number} amount The number of total entity to generate (hard-coded + random)
function Faker:seed(random, amount)
  -- amount is optional
  if not amount then amount = 10000 end

  local entities_to_insert = {
    api = {
      { name = "test",  public_dns = "test.com",  target_url = "http://httpbin.org" },
      { name = "test2", public_dns = "test2.com", target_url = "http://httpbin.org" },
      { name = "test3", public_dns = "test3.com", target_url = "http://httpbin.org" },
      { name = "test4", public_dns = "test4.com", target_url = "http://httpbin.org" },
      { name = "test5", public_dns = "test5.com", target_url = "http://httpbin.org" },
      { name = "test6", public_dns = "test6.com", target_url = "http://httpbin.org" }
    },
    account = {
      { provider_id = "provider_123" },
      { provider_id = "provider_124" }
    },
    application = {
      { public_key = "apikey122", __account = 1 },
      { public_key = "apikey123", __account = 1 },
      { public_key = "username", secret_key = "password", __account = 1 },
    },
    plugin = {
      { name = "authentication", value = { authentication_type = "query",  authentication_key_names = { "apikey" }}, __api = 1 },
      { name = "authentication", value = { authentication_type = "query",  authentication_key_names = { "apikey" }}, __api = 6 },
      { name = "authentication", value = { authentication_type = "header", authentication_key_names = { "apikey" }}, __api = 2 },
      { name = "authentication", value = { authentication_type = "basic" }, __api = 3 },
      { name = "ratelimiting",   value = { period = "minute", limit = 2 }, __api = 5 },
      { name = "ratelimiting",   value = { period = "minute", limit = 2 }, __api = 6 },
      { name = "ratelimiting",   value = { period = "minute", limit = 4 }, __api = 6, __application = 2 }
    }
  }

  self:insert_from_table(entities_to_insert)

  if random then
    -- If we ask for random entities, add as many random entities to another table
    -- as the difference between total amount requested and hard-coded ones
    -- If we ask for 1000 entities, we'll have (1000 - number_of_hard_coded) random entities
    local random_entities = {}
    for type, entities in pairs(entities_to_insert) do
      number_to_insert = amount - #entities
      random_entities[type] = {}
      assert(number_to_insert > 0, "Cannot insert a negative number of elements. Too low amount parameter.")
      for i = 1, number_to_insert do
        table.insert(random_entities[type], self:fake_entity(type))
      end
    end

    self:insert_from_table(random_entities, true)
  end
end

-- Insert entities in the DB using the DAO
-- First accounts and APIs, then the rest which needs references to created accounts and APIs
-- @param {table} entities_to_insert A table with the same structure as the one defined in :seed
-- @param {boolean} random If true, will force applications, plugins and metrics to have relations by choosing
--                         a random entity.
function Faker:insert_from_table(entities_to_insert, random)
  -- Insert in order (for foreign relashionships)
  -- 1. accounts and APIs
  -- 2. applications, plugins and metrics which need refereces to inserted apis and accounts
  for _, type in ipairs({ "api", "account", "application", "plugin" }) do
    for i, entity in ipairs(entities_to_insert[type]) do

      -- Limit the chances of collision between plugins on random insertions
      if random and type == "plugin" then
        entity.api_id = entities_to_insert.api[i].id
      end

      if not random then
        local foreign_api = entities_to_insert.api[entity.__api]
        local foreign_account = entities_to_insert.account[entity.__account]
        local foreign_application = entities_to_insert.application[entity.__application]

        -- Clean this up otherwise won't pass schema validation
        entity.__api = nil
        entity.__account = nil
        entity.__application = nil

        -- Hard-coded foreign relationships
        if type == "application" then
          if foreign_account then entity.account_id = foreign_account.id end
        elseif type == "plugin" then
          if foreign_api then entity.api_id = foreign_api.id end
          if foreign_application then entity.application_id = foreign_application.id end
        end
      end

      -- Insert in DB
      local res, err = self.dao_factory[type.."s"]:insert(entity)
      if err and type ~= "plugin" then
        throw("Failed to insert "..type.." entity: "..inspect(entity).."\n"..inspect(err))
      end

      -- For other hard-coded entities relashionships
      entities_to_insert[type][i] = res

      -- For generated fake_entities
      if not self.inserted_entities[type] then
        self.inserted_entities[type] = {}
      end

      table.insert(self.inserted_entities[type], res)
    end
  end
end

return Faker
