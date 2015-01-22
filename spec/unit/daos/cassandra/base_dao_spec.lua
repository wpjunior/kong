local utils = require "apenode.tools.utils"
local configuration = require "spec.unit.daos.cassandra.configuration"
local JobModel = require "apenode.models.job"

local configuration, dao_factory = utils.load_configuration_and_dao(configuration)

describe("BaseDao", function()

  setup(function()
    --dao_factory:seed(true)
  end)

  teardown(function()
    --dao_factory:drop()
    --dao_factory:close()
  end)

  describe("", function()
    local job, err = JobModel.find_one({id="07f7d9c6-bb02-4287-c2e6-bf5227c8cb7b"}, dao_factory);
    if err then
      ngx.log(ngx.ERR, "Failed to get the job", err)
    else
      job.active = false
      local res, err = job:update()
      if err then
        ngx.log(ngx.ERR, "Failed to update the job", err)
      end
    end
  end)

end)
