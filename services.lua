
local services = {
    {name = "lib", svc = require("libs.libService")}
}

return setmetatable({}, {
    __index = function(t, k)
        for i, v in ipairs(services) do
            if v.name == k then
                return v.svc
            end
        end
    end
})