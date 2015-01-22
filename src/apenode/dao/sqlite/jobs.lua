local BaseDao = require "apenode.dao.sqlite.base_dao"
local JobModel = require "apenode.models.job"

local Jobs = BaseDao:extend()

function Jobs:new(database)
  Jobs.super.new(self, database, JobModel._COLLECTION, JobModel._SCHEMA)
end

return Jobs
