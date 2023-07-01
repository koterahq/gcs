local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage:FindFirstChild("Fusion", true))
local Red = require(ReplicatedStorage:FindFirstChild("Red", true))

local GCS = {}
local Bridge = Red.Client("koterahq.gcs")

function GCS.init()
    GCS.logBucket = {}
end

function GCS.log(message)
    table.insert(GCS.logBucket, {
        timestamp = os.time(),
        message = message,
    })
end

function GCS.dispatch(event, ...)
    return Bridge:Call(event, ...):Then(function(status, response)
        return status, response
    end)
end

return GCS