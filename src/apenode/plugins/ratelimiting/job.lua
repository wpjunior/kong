-- Copyright (C) Mashape, Inc.

local BaseJob = require "apenode.base_job"

local RateLimitingJob = BaseJob:extend()

function RateLimitingJob.execute(job_id)
  RateLimitingJob.super.start(job_id)


  -- DO SOMETHING


  -- This is mandatory and tells the system that the job is terminated
  RateLimitingJob.super.complete(job_id)
end

return RateLimitingJob
