local utils = require "apenode.tools.utils"
local configuration = require "spec.unit.daos.cassandra.configuration"
local MetricModel = require "apenode.models.metric"

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
    it("should work", function()

      --[[
      local res, err = dao_factory.metrics:delete_older_than(1521977435798, "second")
      local inspect = require "inspect"
      print(inspect(res))
      print(inspect(err))
      --[[
      local res, err = dao_factory.metrics:increment("4d924084-1adb-40a5-c042-63b19db425d2",
                                                          "4d924084-1adb-40a5-c042-63b19db425d2",
                                                          nil,
                                                          "new_metric_2",
                                                          1421977435798,
                                                          "second")
      assert.falsy(err)
      assert.truthy(res)
      --]]
    end)
  end)

end)
