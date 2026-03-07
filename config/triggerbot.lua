local configJson = lje.data.read("gilbhax-triggerbot-config")
if configJson then
    local config = util.JSONToTable(configJson)
    if config then
        config.save = function(self)
            local configJson = util.TableToJSON(self, true)
            lje.data.write("gilbhax-triggerbot-config", configJson)
        end
        return config
    end
end

return {
    enabled = true,
    save = function(self)
        local configJson = util.TableToJSON(self, true)
        lje.data.write("gilbhax-triggerbot-config", configJson)
    end
}