local _module = {
    INFO = 0,
    WARNING = 1,
    ERROR = 2
}

local _show_info_type = true

local _show_time = true

local _show_caller_info = true

--[[
    描述：
        将调试信息输出至控制台
    参数：
        - content   [string]    调试信息
        - type      [number]    信息类型，默认为 Debug.INFO
    返回值：
        [无]
    示例：
        Debug.Log("HelloWorld", Debug.WARN)
        可能的输出为：[INFO][21-08-12 09:24:37][./scripts/VisualConsole.lua[21]:PushText]HelloWorld
--]]
_module.ConsoleLog = function(content, type)
    content = content or ""

    if _show_caller_info then
        local _debug_info = debug.getinfo(2)
        content = string.format(
            "[%s[%s]:%s]",
            _debug_info.short_src,
            _debug_info.currentline,
            _debug_info.name
        )..content
    end

    if _show_time then
        content = string.format(
            "[%s]",
            os.date("%y-%m-%d %H:%M:%S")
        )..content
    end

    if _show_info_type then
        if type == _module.INFO then
            content = "[INFO]"..content
        elseif type == _module.WARNING then
            content = "[WARN]"..content
        elseif type == _module.ERROR then
            content = "[ERROR]"..content
        else
            content = "[INFO]"..content
        end
    end    

    print(content)
end

--[[
    描述：
        设置输出内容中是否包含信息类型
    参数：
        - flag  [boolean]   是否包含信息类型
    返回值：
        [无]
    示例：
        默认包含信息类型的情况下可能输出：[INFO][21-08-12 09:24:37][./scripts/VisualConsole.lua[21]:PushText]HelloWorld
        关闭信息类型后的输出：[21-08-12 09:24:37][./scripts/VisualConsole.lua[21]:PushText]HelloWorld
--]]
_module.SetInfoTypeShow = function(flag)
    _show_info_type = flag
end

--[[
    描述：
        设置输出内容中是否包含时间信息
    参数：
        - flag  [boolean]   是否包含时间信息
    返回值：
        [无]
    示例：
        默认包含时间信息的情况下可能输出：[INFO][21-08-12 09:24:37][./scripts/VisualConsole.lua[21]:PushText]HelloWorld
        关闭时间信息后的输出：[INFO][./scripts/VisualConsole.lua[21]:PushText]HelloWorld
--]]
_module.SetTimeShow = function(flag)
    _show_time = flag
end

--[[
    描述：
        设置输出内容中是否包含调用者信息
    参数：
        - flag  [boolean]   是否包含调用者信息
    返回值：
        [无]
    示例：
        默认包含调用者信息的情况下可能输出：[INFO][21-08-12 09:24:37][./scripts/VisualConsole.lua[21]:PushText]HelloWorld
        关闭调用者信息后的输出：[INFO][21-08-12 09:24:37]HelloWorld
--]]
_module.SetCallerInfoShow = function(flag)
    _show_caller_info = flag
end

return _module