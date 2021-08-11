Scene = UsingModule("Scene")
Resource = UsingModule("Resource")
Window = UsingModule("Window")
Interactivity = UsingModule("Interactivity")
Algorithm = UsingModule("Algorithm")

TheWorld = {}
TheWorld = Scene.BaseScene:New()

local BackgroundRect = {x = 0, y = 0, w = Global.WINDOWSIZE_W, h = 300}
local BackgroundShape = {x = 0, y = 0, w = Global.WINDOWSIZE_W, h = 300}
local Background2Rect = {x = Global.WINDOWSIZE_W, y = 0, w = 0, h = 300}
local Background2Shape = {x = 0, y = 0, w = 0, h = 300}

local MountainRect = {x = 0, y = 0, w = 1600, h = Global.WINDOWSIZE_H}
local Mountain2Rect = {x = 1600, y = 0, w = 1600, h = Global.WINDOWSIZE_H}

function TheWorld.Init()
    TheWorld.sky = Graphic.CreateTexture(Resource.sky)
    TheWorld.mountain = Graphic.CreateTexture(Resource.mountain)
    Resource.CreateWorld()
    Resource.Leader.Layer = 1
    table.insert(Resource.vObjectTable, 1, Resource.Leader)
    Resource.Camera.Init(Resource.Leader)
end

--玩家目前按下的某个方向的键
local _Direction = {left = false, right = false, up = false}
--角色正在朝向移动的方向
local _MoveState = {left = false, right = false, up = false, down = false}
--判断是否有方块阻挡玩家移动
local function canMove()
    if _MoveState.left then
        local CollisionY1 = math.ceil((Resource.Leader.Rect.y + 90) / 30)
        local CollisionY2 = math.ceil((Resource.Leader.Rect.y + 60) / 30)
        local CollisionY3 = math.ceil((Resource.Leader.Rect.y + 30) / 30)
        local CollisionX = math.floor((Resource.Leader.Rect.x + Resource.Leader.xSpeed + 2) / 30) + 1
        if Resource.Map[CollisionY1][CollisionX] == 0 and Resource.Map[CollisionY2][CollisionX] == 0 and Resource.Map[CollisionY3][CollisionX] == 0 then
            return true
        else
            _MoveState.left = false
            Resource.Leader.xSpeed = 0
            return false
        end
    elseif _MoveState.right then
        local CollisionY1 = math.ceil((Resource.Leader.Rect.y + 90) / 30)
        local CollisionY2 = math.ceil((Resource.Leader.Rect.y + 60) / 30)
        local CollisionY3 = math.ceil((Resource.Leader.Rect.y + 30) / 30)
        local CollisionX = math.floor((Resource.Leader.Rect.x + Resource.Leader.xSpeed + 28) / 30) + 1
        if Resource.Map[CollisionY1][CollisionX] == 0 and Resource.Map[CollisionY2][CollisionX] == 0 and Resource.Map[CollisionY3][CollisionX] == 0 then
            return true
        else
            _MoveState.right = false
            Resource.Leader.xSpeed = 0
            return false
        end
    end
end

function TheWorld.Update()
    Window.ClearWindow()

    while Interactivity.UpdateEvent() do
        local event = Interactivity.GetEventType()
        if event == Interactivity.EVENT_QUIT then
            TheWorld.nRtnValue = -1
        elseif event == Interactivity.EVENT_KEYDOWN_LEFT then
            _Direction.left = true
        elseif event == Interactivity.EVENT_KEYUP_LEFT then
            _Direction.left = false
        elseif event == Interactivity.EVENT_KEYDOWN_RIGHT then
            _Direction.right = true
        elseif event == Interactivity.EVENT_KEYUP_RIGHT then
            _Direction.right = false
        elseif event == Interactivity.EVENT_KEYDOWN_UP then
            _Direction.up = true
        elseif event == Interactivity.EVENT_KEYUP_UP then
            _Direction.up = false
        end
    end

    --如果开始移动,则将玩家的速度加上加速度的值直到达到最大速度
    if Resource.Leader.xSpeed == 0 and _Direction.left and _Direction.right == false and _MoveState.left == false then
        _MoveState.left = true
    end
    --如果当前速度小于最大速度且玩家依旧命令角色移动,则继续增加
    if _MoveState.left and _Direction.left and math.abs(Resource.Leader.xSpeed) < Resource.Leader.xMaxSpeed then
        Resource.Leader.xSpeed = Resource.Leader.xSpeed - Resource.Leader.Acceleration
    end
    --如果当前速度超过了最大速度,则强制赋值为最大速度
    if math.abs(Resource.Leader.xSpeed) >= Resource.Leader.xMaxSpeed and _MoveState.left and _Direction.left then
        Resource.Leader.xSpeed = 0 - Resource.Leader.xMaxSpeed
    end
    --如果玩家没有命令角色移动,则慢慢减速
    if _MoveState.left and _Direction.left == false then
        Resource.Leader.xSpeed = Resource.Leader.xSpeed + Resource.Leader.Acceleration
    end
    --如果玩家减速过头,则强制赋值速度为0,且取消角色向左移动的状态
    if _MoveState.left and Resource.Leader.xSpeed >= 0 then
        Resource.Leader.xSpeed = 0
        _MoveState.left = false
    end

    --[下列为向右的情况]
    if Resource.Leader.xSpeed == 0 and _Direction.right and _Direction.left == false and _MoveState.right == false then
        _MoveState.right = true
    end
    if _MoveState.right and _Direction.right and Resource.Leader.xSpeed < Resource.Leader.xMaxSpeed then
        Resource.Leader.xSpeed = Resource.Leader.xSpeed + Resource.Leader.Acceleration
    end
    if Resource.Leader.xSpeed >= Resource.Leader.xMaxSpeed and _MoveState.right and _Direction.right then
        Resource.Leader.xSpeed = Resource.Leader.xMaxSpeed
    end
    if _MoveState.right and _Direction.right == false then
        Resource.Leader.xSpeed = Resource.Leader.xSpeed - Resource.Leader.Acceleration
    end
    if _MoveState.right and Resource.Leader.xSpeed <= 0 then
        Resource.Leader.xSpeed = 0
        _MoveState.right = false
    end

    --跳跃的情况,以及下落
    local tempCollisionX1 = math.ceil((Resource.Leader.Rect.x + 2) / 30)
    local tempCollisionX2 = math.ceil((Resource.Leader.Rect.x + 28) / 30)
    local tempCollisionY1 = math.floor((Resource.Leader.Rect.y + Resource.Leader.ySpeed + 90) / 30) + 1
    local tempCollisionY2 = math.floor((Resource.Leader.Rect.y + Resource.Leader.ySpeed + 30) / 30) + 1
    --如果玩家脚下没有方块,那么他将自由落体
    if Resource.Map[tempCollisionY1][tempCollisionX1] == 0 and Resource.Map[tempCollisionY1][tempCollisionX2] == 0 then
        if Resource.Leader.ySpeed < 0 and _MoveState.up == false then
            _MoveState.up = true
        elseif Resource.Leader.ySpeed < 0 and _MoveState.up then
            Resource.Leader.ySpeed = Resource.Leader.ySpeed + Global.GRAVITY
        elseif Resource.Leader.ySpeed >= 0 and _MoveState.up then
            _MoveState.up = false
            _MoveState.down = true
        elseif Resource.Leader.ySpeed >= 0 and Resource.Leader.ySpeed < Resource.Leader.yMaxSpeed and _MoveState.down then
            Resource.Leader.ySpeed = Resource.Leader.ySpeed + Global.GRAVITY
        elseif Resource.Leader.ySpeed >= Resource.Leader.yMaxSpeed and _MoveState.down then
            Resource.Leader.ySpeed = Resource.Leader.yMaxSpeed
        end
        if Resource.Leader.ySpeed == 0 and _MoveState.down == false and _MoveState.up == false then
            _MoveState.down = true
            Resource.Leader.ySpeed = Resource.Leader.ySpeed + Global.GRAVITY
        end
    --如果玩家脚下有方块,那么玩家将瞬间静止
    elseif Resource.Map[tempCollisionY1][tempCollisionX1] ~= 0 or Resource.Map[tempCollisionY1][tempCollisionX2] ~= 0 then
        if _MoveState.down then
            Resource.Leader.ySpeed = 0
            Resource.Leader.Rect.y = tempCollisionY1 * 30 - 120
            _MoveState.down = false
        end
        if _Direction.up then
            Resource.Leader.ySpeed = 0 - Resource.Leader.JumpAbility
        end
    end
    --如果玩家头顶有方块阻挡,则玩家瞬间速度为0,且开始下落
    if (Resource.Map[tempCollisionY2][tempCollisionX1] ~= 0 or Resource.Map[tempCollisionY2][tempCollisionX2] ~= 0) and _MoveState.up then
        _MoveState.up = false
        _MoveState.down = true
        Resource.Leader.ySpeed = 0
    end

    --每帧更新玩家的位置
    if canMove() then
        Resource.Leader.Rect.x = Resource.Leader.Rect.x + Resource.Leader.xSpeed
    end
    --每帧更新玩家Y轴的位置
    Resource.Leader.Rect.y = Resource.Leader.Rect.y + Resource.Leader.ySpeed

    --绘制背景的山,两张图片循环进行,且根据玩家的移动来移动
    if _MoveState.left and _MoveState.right == false and Resource.Camera.Rect.x ~= 0 and (Resource.Camera.Rect.x + Resource.Camera.Rect.w) ~= 2000 * 30 and canMove() then
        if MountainRect.x > 0 then
            Mountain2Rect.x = MountainRect.x
            MountainRect.x = Mountain2Rect.x - 1600
            Graphic.CopyTexture(TheWorld.mountain, MountainRect)
            Graphic.CopyTexture(TheWorld.mountain, Mountain2Rect)
        elseif MountainRect.x <= 0 then
            MountainRect.x = MountainRect.x + math.abs(Resource.Leader.xSpeed / 5)
            Mountain2Rect.x = MountainRect.x + 1600
            Graphic.CopyTexture(TheWorld.mountain, MountainRect)
            Graphic.CopyTexture(TheWorld.mountain, Mountain2Rect)
        end
    elseif _MoveState.right and _MoveState.left == false and(Resource.Camera.Rect.x + Resource.Camera.Rect.w) ~= 2000 * 30 and Resource.Camera.Rect.x ~= 0 and canMove() then
        if Mountain2Rect.x < 0 then
            MountainRect.x = Mountain2Rect.x
            Mountain2Rect.x = MountainRect.x + 1600
            Graphic.CopyTexture(TheWorld.mountain, MountainRect)
            Graphic.CopyTexture(TheWorld.mountain, Mountain2Rect)
        elseif Mountain2Rect.x >= 0 then
            MountainRect.x = MountainRect.x - math.abs(Resource.Leader.xSpeed / 5)
            Mountain2Rect.x = MountainRect.x + 1600
            Graphic.CopyTexture(TheWorld.mountain, MountainRect)
            Graphic.CopyTexture(TheWorld.mountain, Mountain2Rect)
        end
    else
        Graphic.CopyTexture(TheWorld.mountain, MountainRect)
        Graphic.CopyTexture(TheWorld.mountain, Mountain2Rect)
    end

    --绘制背景,两张天空图片循环进行
    if BackgroundShape.x <= 400 then
        Graphic.CopyReshapeTexture(TheWorld.sky, BackgroundShape, BackgroundRect)
        BackgroundShape.x = BackgroundShape.x + 1
     elseif BackgroundShape.x > 400 and BackgroundShape.x <= 1600 then
         Graphic.CopyReshapeTexture(TheWorld.sky, BackgroundShape, BackgroundRect)
         BackgroundShape.x = BackgroundShape.x + 1
         BackgroundShape.w = BackgroundShape.w - 1
         BackgroundRect.w = BackgroundRect.w - 1
         Graphic.CopyReshapeTexture(TheWorld.sky, Background2Shape, Background2Rect)
         Background2Rect.x = BackgroundRect.w
         Background2Rect.w = Global.WINDOWSIZE_W - BackgroundRect.w
         Background2Shape.w = Global.WINDOWSIZE_W - BackgroundRect.w
     elseif BackgroundShape.x > 1600 then
         Graphic.CopyReshapeTexture(TheWorld.sky, Background2Shape, Background2Rect)
         BackgroundShape.x = 0
         BackgroundShape.w = Global.WINDOWSIZE_W
         BackgroundRect.w = Global.WINDOWSIZE_W
         Background2Rect.x = Global.WINDOWSIZE_W
         Background2Rect.w = 0
         Background2Shape.w = 0
     end

    --摄像机输出
    Resource.Camera.Output()

    Window.UpdateWindow()
end

function TheWorld.Unload()
    TheWorld.sky = nil
    TheWorld.mountain = nil
end

return TheWorld