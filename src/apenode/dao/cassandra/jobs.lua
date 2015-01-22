local BaseDao = require "apenode.dao.cassandra.base_dao"
local JobModel = require "apenode.models.job"

local Jobs = BaseDao:extend()

function Jobs:new(database, properties)
  Jobs.super.new(self, database, JobModel._COLLECTION, JobModel._SCHEMA, properties)
end

return Jobs
