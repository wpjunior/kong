-- Copyright (C) Mashape, Inc.

local utils = require "apenode.tools.utils"
local BaseModel = require "apenode.models.base_model"

local COLLECTION = "jobs"
local SCHEMA = {
  id = { type = "id", read_only = true },
  name = { type = "string", required = true },
  active = { type = "boolean", required = true },
  stopped = { type = "boolean", required = false },
  created_at = { type = "timestamp", read_only = false, default = utils.get_utc }
}

local Job = BaseModel:extend()

Job["_COLLECTION"] = COLLECTION
Job["_SCHEMA"] = SCHEMA

function Job:new(t, dao_factory)
  Job.super.new(self, COLLECTION, SCHEMA, t, dao_factory)
end

function Job.find_one(args, dao_factory)
  local data, err =  Job.super._find_one(args, dao_factory[COLLECTION])
  if data then
    data = Job(data, dao_factory)
  end
  return data, err
end

function Job.find(args, page, size, dao_factory)
  local data, total, err = Job.super._find(args, page, size, dao_factory[COLLECTION])
  if data then
    for i,v in ipairs(data) do
      data[i] = Job(v, dao_factory)
    end
  end
  return data, total, err
end

return Job
