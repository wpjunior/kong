-- Copyright (C) Mashape, Inc.

local Object = require "classic"

local Jobs = Object:extend()

local function find_plugin(name)
  for _,v in ipairs(plugins) do
    if v.name == name then
      return v
    end
  end
end

function Jobs:new()

  app:get("/jobs/:plugin_name/start", function(self)
    local plugin = find_plugin(self.params.plugin_name)
    if plugin then
      plugin.handler:job()
      return utils.success("Jobs started")
    else
      return utils.not_found("Job not found")
    end
  end)

end

return Jobs