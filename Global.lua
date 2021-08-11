Time = UsingModule("Time")

Global = {}

Global.WINDOWSIZE_W = 1200
Global.WINDOWSIZE_H = 900

Global.GRAVITY = 1

--计时器模块
local _tempTimer = {delay = 0, callback = nil, params = {}}

local TimerList = {}

function Global.AddTimer(delay, callback, params)
    _tempTimer.delay, _tempTimer.callback, _tempTimer.params = Time.GetInitTime() + delay, callback, params
    table.insert(TimerList, _tempTimer)
end

function Global.UpdateTimer()
    local currentTime = Time.GetInitTime()
    for k, v in ipairs(TimerList) do
        if v.delay <= currentTime then
            v.callback(v.params)
            table.remove(TimerList, k)
        end
    end
end

function Global.ClearAll()
    TimerList = {}
end


return Global