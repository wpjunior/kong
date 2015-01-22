local cjson = require "cjson"

local _M = {}

function _M.serialize(schema, entity)
  if entity then
    for k,v in pairs(schema) do
      if entity[k] ~= nil and v.type == "table" then
        entity[k] = cjson.encode(entity[k])
      end
    end
  end
  return entity
end

function _M.deserialize(schema, entity)
  if entity then
    for k,v in pairs(schema) do
      if entity[k] ~= nil and v.type == "table" then
        entity[k] = cjson.decode(entity[k])
      elseif entity[k] ~= nil and v.type == "string" then
        entity[k] = tostring(entity[k])
      elseif entity[k] ~= nil and v.type == "boolean" then
        if entity[k] == 1 or entity[k] == true then
          entity[k] = true
        elseif entity[k] == 0 or entity[k] == false then
          entity[k] = false
        else
          error("Unknown boolean value ", entity[k])
        end
      end
    end
  end
  return entity
end

return _M
