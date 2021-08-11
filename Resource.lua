Graphic = UsingModule("Graphic")

Resource = {}

Resource.simhei = Graphic.LoadFontFromFile("Resource/Font/simhei.ttf", 50)
Resource.block = Graphic.LoadImageFromFile("Resource/Image/block.png")
Resource.sky = Graphic.LoadImageFromFile("Resource/Image/Sky.png")
Resource.mountain = Graphic.LoadImageFromFile("Resource/Image/Mountain.png")

local block = Graphic.CreateTexture(Resource.block)

--绿幕角色
Resource.CharacterImage = Graphic.LoadImageFromFile("Resource/Image/Character.png")
Resource.CharacterImage:SetColorKey(true, {r = 0, g = 255, b = 0, a = 255})

--初始主角信息
Resource.Leader =
{
    Rect = {x = 1950 * 30, y = 195 * 30, w = 30, h = 90},
    Image = Graphic.CreateTexture(Resource.CharacterImage),
    layer = nil,
    xSpeed = 0,
    ySpeed = 0,
    xMaxSpeed = 8,
    yMaxSpeed = 15,
    Acceleration = 0.8,
    AcclerationY = 0
    --Health = 20,
    --Hunger = 100,
    --Package = {}
}

local Material = {}
--方块在素材中的矩形位置
for i = 1, 7 do
    Material[i] = 
    {
        Rect = {
            x = (i - 1) * 100,
            y = 0,
            w = 100,
            h = 100
        }
    }
end

--生成一个400格高,2000格宽的世界(规模有点大呢)
Resource.Map = {}
function Resource.CreateWorld()
    local treeAmount = math.random(60, 80)
    local mineralAmount = math.random(2000, 2500)
    for i = 1, 400 do
        Resource.Map[i] = {}
    end
    for i = 1, 199 do
        for j = 1, 2000 do
            Resource.Map[i][j] = 0
        end
    end
    for i = 200, 210 do
        for j = 1, 2000 do
            Resource.Map[i][j] = 1
        end
    end
    for j = 1, 2000 do
        Resource.Map[200][j] = 2
    end
    print("正在生成石头,20%")
    for i = 211, 400 do
        for j = 1, 2000 do
            Resource.Map[i][j] = 3
        end
    end
    print("正在生成矿石,50%")
    for j = 1, mineralAmount do
        local xPosition = math.random(1, 2000)
        local yPosition = math.random(211, 400)
        Resource.Map[yPosition][xPosition] = math.random(4, 5)
    end
    print("正在生成树,75%")
    for j = 1, treeAmount do
        local nPosition = math.random(1, 2000)
        local nHeight = math.random(5, 7)
        for i = 199, 199 - nHeight, -1 do
            Resource.Map[i][nPosition] = 6
        end
        --生成树叶(暂时用比较固定的生成方法)(顶部按531的顺序排上去...)
        for i = 1, 5 do
            Resource.Map[199 - nHeight][nPosition - 3 + i] = 7
        end
        for i = 1, 3 do
            Resource.Map[199 - nHeight - 1][nPosition - 2 + i] = 7
        end
        Resource.Map[199 - nHeight - 2][nPosition] = 7
    end
    print("超平坦世界生成完毕")
end

--对象表,每个对象应当拥有Rect(绘制矩形),Image(纹理数据),layer(图层)
Resource.vObjectTable = {}

Resource.Camera = 
{
    --摄像机拍摄的范围(一般是跟随玩家)
    Rect = {x = 0, y = 0, w = Global.WINDOWSIZE_W, h = Global.WINDOWSIZE_H},
    --摄像机跟随的速度
    Speed = 10,
    --摄像机跟随的对象
    Object = nil
}

--选取摄像机跟随的对象并初始化
function Resource.Camera.Init(object)
    Resource.Camera.Object = object
    table.sort(Resource.vObjectTable, function (a, b)
        if a ~= nil and b ~= nil then
            return (a.Layer < b.Layer)
        end
    end)
    Resource.Camera.Rect.x = Resource.Camera.Object.Rect.x - Global.WINDOWSIZE_W / 2
    Resource.Camera.Rect.y = Resource.Camera.Object.Rect.y - Global.WINDOWSIZE_H / 1.5
end

--将摄像机拍摄到的图像打印在屏幕上
local _tempRect = {x = 0, y = 0, w = 0, h = 0}
function Resource.Camera.Output()
    if Resource.Camera.Rect.x >= 0 and Resource.Camera.Rect.y >= 0 and Resource.Camera.Rect.x <= 2000 * 30 and Resource.Camera.Rect.y <= 400 * 30 then
        Resource.Camera.Rect.x = Resource.Camera.Object.Rect.x - Global.WINDOWSIZE_W / 2
        Resource.Camera.Rect.y = Resource.Camera.Object.Rect.y - Global.WINDOWSIZE_H / 1.5
    end
    if Resource.Camera.Rect.x < 0 then
        Resource.Camera.Rect.x = 0
    elseif Resource.Camera.Rect.x + Resource.Camera.Rect.w > 2000 * 30 then
        Resource.Camera.Rect.x = 2000 * 30 - Resource.Camera.Rect.w
    elseif Resource.Camera.Rect.y < 0 then
        Resource.Camera.Rect.y = 0
    elseif Resource.Camera.Rect.y + Resource.Camera.Rect.h > 400 * 30 then
        Resource.Camera.Rect.y = 400 * 30 - Resource.Camera.Rect.h
    end
    _tempRect.w, _tempRect.h = 30, 30
    for i = math.floor(Resource.Camera.Rect.x / 30) + 1, math.ceil((Resource.Camera.Rect.x + Resource.Camera.Rect.w) / 30) do
        for j = math.floor(Resource.Camera.Rect.y / 30) + 1, math.ceil((Resource.Camera.Rect.y + Resource.Camera.Rect.h) / 30) do
            _tempRect.x, _tempRect.y = (i - 1) * 30 - Resource.Camera.Rect.x, (j - 1) * 30 - Resource.Camera.Rect.y
            if Resource.Map[j][i] ~= 0 then
                Graphic.CopyReshapeTexture(block, Material[Resource.Map[j][i]].Rect, _tempRect)
            end
        end
    end
    for k, v in ipairs(Resource.vObjectTable) do
        _tempRect.x, _tempRect.y = v.Rect.x - Resource.Camera.Rect.x, v.Rect.y - Resource.Camera.Rect.y
        _tempRect.w, _tempRect.h = v.Rect.w, v.Rect.h
        Graphic.CopyTexture(v.Image, _tempRect)
    end
end

return Resource