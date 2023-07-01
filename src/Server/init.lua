local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage:FindFirstChild("Red", true))

local GCS = {}
local API = require(script.API)
local Bridge = Red.Server("koterahq.gcs")
local BridgeRateLimit = Red.RateLimit(6, 1)

function GCS.auth(player, scope)
    if GCS.config.authHandler then
        return GCS.config.authHandler(player, scope)
    else
        warn("There is no authentification handler setup for GCS. GCS will deny all player requests.")
        return false
    end
end

function GCS.execAPI(api, arguments)
    local path = string.split(api, ".")
    local node = API

    for index, segment in path do
        node = node[segment]
        if not node or (index ~= #path and type(node) ~= "table") then
            return false, `API "{api}" not found.`
        end
    end

    return pcall(node, arguments)
end

function GCS.exec(command, arguments)
    if not GCS.config.commands or not GCS.config.commands[command] then
        return false, `Command "{command}" not found.`
    end
    local command = GCS.config.commands[command]

    return pcall(command.invoke, arguments)
end

function GCS.log(message)
    table.insert(GCS.logBucket, {
        timestamp = os.time(),
        message = message,
    })
end

function GCS.init(config)
    GCS.config = config
    GCS.logBucket = {}

    Bridge:On("api", function(player, api, arguments)
        
        if BridgeRateLimit(player) and GCS.auth(player, "api") then
            local status, response = GCS.execAPI(api, arguments)
            if status then
                GCS.log(`{player.Name} ({player.UserId}) executed API "{api}"`)
            end

            return status, response
        end

        return false, "Not authorized to use the API."
    end)

    Bridge:On("exec", function(player, command, arguments)
        if BridgeRateLimit(player) and GCS.auth(player, "execCmd") then
            local status, response = GCS.exec(command, arguments)
            if status then
                GCS.log(`{player.Name} ({player.UserId}) executed command "{command}"`)
            end

            return status, response
        end

        return false, "Not authorized to execute commands."
    end)
end

return GCS