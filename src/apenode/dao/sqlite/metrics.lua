local BaseDao = require "apenode.dao.sqlite.base_dao"
local MetricModel = require "apenode.models.metric"

local Metrics = BaseDao:extend()

function Metrics:new(database)
  Metrics.super.new(self, database, MetricModel._COLLECTION, MetricModel._SCHEMA)

  self.prepared_stmts = {}

  self.stmts = {
    increment = [[
      INSERT OR REPLACE INTO metrics
        VALUES (:api_id, :application_id, :origin_ip, :name, :timestamp, :period,
          COALESCE(
          (SELECT value FROM metrics WHERE api_id = :api_id
                                       AND application_id = :application_id
                                       AND origin_ip = :origin_ip
                                       AND name = :name
                                       AND timestamp = :timestamp
                                       AND period = :period),
          0) + :step
      );
    ]],
    deleted_older_than = [[
      DELETE FROM metrics WHERE period = :period
                            AND timestamp < :timestamp
    ]]
  }
end

function Metrics:prepare()
  for k,stmt in pairs(self.stmts) do
    self.prepared_stmts[k] = Metrics.super.get_statement(self, stmt)
  end
end

-- @override
function Metrics:insert_or_update()
  error("Metrics:insert_or_update() not supported")
end

-- @override
function Metrics:find_one(args)
  return Metrics.super.find_one(self, {
    api_id = args.api_id,
    application_id = args.application_id,
    origin_ip = args.ip,
    name = args.name,
    period = args.period,
    timestamp = args.timestamp
  })
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

  self.prepared_stmts.increment:bind_names {
    api_id = api_id,
    application_id = stmt_application_id,
    origin_ip = stmt_ip,
    name = name,
    timestamp = timestamp,
    period = period,
    step = step
  }

  local count, err = self:exec_stmt_count_rows(self.prepared_stmts.increment)
  if err or count == 0 then
    return false, err
  end

  return true
end

function Metrics:delete_older_than(timestamp, period)
  self.prepared_stmts.deleted_older_than:bind_names {
    period = period,
    timestamp = timestamp
  }

  return self:exec_stmt_count_rows(self.prepared_stmts.deleted_older_than)
end

return Metrics
