local BaseDao = require "apenode.dao.cassandra.base_dao"
local MetricModel = require "apenode.models.metric"

local Metrics = BaseDao:extend()

function Metrics:new(database, properties)
  Metrics.super.new(self, database, MetricModel._COLLECTION, MetricModel._SCHEMA, properties)
end

-- @override
function Metrics:insert_or_update()
  error("Metrics:insert_or_update() not supported")
end

function Metrics:increment(api_id, application_id, origin_ip, name, timestamp, period, step)
  if not step then step = 1 end

  -- application_id and origin_ip cannot be NULL, so...
  local stmt_application_id = ""
  local stmt_ip = ""

  if origin_ip ~= nil then
    stmt_ip = origin_ip
  else
    stmt_application_id = application_id
  end

  local where_keys = {
    api_id = api_id,
    application_id = stmt_application_id,
    origin_ip = stmt_ip,
    name = name,
    period = period,
    timestamp = timestamp
  }

  local _, _, where_values_to_bind = Metrics.super._build_query_args(self, where_keys)
  local where = Metrics.super._build_where_fields(where_keys)

  local query = [[ UPDATE ]]..MetricModel._COLLECTION..[[ SET value = value + ]]..tostring(step)..where

  local res, err = self:_exec_stmt(query, where_values_to_bind)
  if err then
    return false, err
  end

  return true
end

function Metrics:delete_older_than(timestamp, period)
  local where_keys = {
    period = period
  }

  local where = Metrics.super._build_where_fields(where_keys)
  local query = [[ DELETE FROM ]]..MetricModel._COLLECTION..where.." AND timestamp < ?"

  where_keys["timestamp"] = timestamp
  local _, _, where_values_to_bind = Metrics.super._build_query_args(self, where_keys)

  local res, err = self:_exec_stmt(query, where_values_to_bind)
  if err then
    return false, err
  end

  return true
end

return Metrics
