-- Copyright (C) Mashape, Inc.

local Object = require "classic"
local JobModel = require "apenode.models.job"
local BaseController = require "apenode.web.routes.base_controller"

local Jobs = Object:extend()

local function find_plugin(name)
  for _,v in ipairs(plugins) do
    if v.name == name then
      return v
    end
  end
end

local function find_plugins_with_job()
  local result = {}
  for _,v in ipairs(plugins) do
    local metatable = getmetatable(v.handler)
    for k,_ in pairs(getmetatable(v.handler)) do
      if k == "job" then
        table.insert(result, v.name)
      end
    end
  end
  return result
end

local function find_jobs(active, req, query_params)
  local params = BaseController.parse_params(JobModel, query_params)

  local page = 1
  local size = 10
  if params.page and tonumber(params.page) > 0 then
    page = tonumber(params.page)
  else
    page = 1
  end
  if params.size and tonumber(params.size) > 0 then
    size = tonumber(params.size)
  else
    size = 10
  end
  params.size = nil
  params.page = nil

  local data, total, err = JobModel.find({ active = active }, page, size, dao)
  if err then
    return utils.show_error(500, err)
  end
  return utils.success(BaseController.render_list_response(req, data, total, page, size))
end

function Jobs:new()

  app:post("/jobs/:plugin_name/start", function(self)
    local plugin = find_plugin(self.params.plugin_name)
    if plugin then
      local data, err = JobModel({
        name = plugin.name,
        active = true
      }, dao):save()
      if err then
        return utils.show_error(500, err)
      else
        ngx.timer.at(0, plugin.handler.job, data.id)
        return utils.success("Jobs started")
      end
    else
      return utils.not_found("Job not found")
    end
  end)

  app:get("/jobs/available", function(self)
    return utils.success(find_plugins_with_job())
  end)

  app:get("/jobs/active", function(self)
    return find_jobs(true, self.req, self.params)
  end)

  app:get("/jobs/completed", function(self)
    return find_jobs(false, self.req, self.params)
  end)

end

return Jobs