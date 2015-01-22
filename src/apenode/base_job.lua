-- Copyright (C) Mashape, Inc.

local Job = require "apenode.models.job"
local Object = require "classic"
local BaseJob = Object:extend()

function BaseJob.start(job_id)
  ngx.log(ngx.DEBUG, " started job with id " .. job_id)
end

function BaseJob.complete(job_id)
  local job, err = Job.find_one({id=job_id}, dao);
  if err then
    ngx.log(ngx.ERR, "Failed to get the job", err)
  else
    job.active = false
    local res, err = job:update()
    if err then
      ngx.log(ngx.ERR, "Failed to update the job", err)
    end
  end
end

return BaseJob