local GCS = require(script.Parent.Parent)

return function(player, scope)
    if not GCS.config.admins or not GCS.config.admins[player.UserId] then
        return false
    else
        local entry = GCS.config.admins[player.UserId]
        if table.find(entry.scopes, scope) then
            return true
        else
            return false
        end
    end
end