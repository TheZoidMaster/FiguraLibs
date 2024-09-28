--[[
  _____     _     _     ___ _  __
 |__  /___ (_) __| |___|_ _| |/ /
   / // _ \| |/ _` / __|| || ' /
  / /| (_) | | (_| \__ \| || . \
 /____\___/|_|\__,_|___/___|_|\_\
--]]

--- Zoid's IK implementation
--- https://github.com/TheZoidMaster/FiguraLibs/tree/main/ZoidsIK


--- Rotation helper function - thank you @4p5
--- @param dir Vector3
local function dirToAngle(dir)
    return vec(math.deg(math.atan2(dir.y, math.sqrt(dir.x * dir.x + dir.z * dir.z))),
        math.deg(math.atan2(dir.x, dir.z)), 0)
end

--- Chain class
--- @class IKChain
local IKChain = {
    parts = {},
    joints = {},
    lengths = {},
    totalLength = 0,
    root = vectors.vec3(0, 0, 0),
    target = vectors.vec3(0, 0, 0),
    autoPause = true,
    name = ""
}

--- Creates a new chain.
---
--- All modelparts in the chain will be moved to `models.ik.<name>`.
--- @param parts table
--- @param lengths table
--- @param name string
--- @return IKChain
function IKChain.new(parts, lengths, name)
    local self = {}
    setmetatable(self, { __index = IKChain })
    self.lengths = lengths
    self.totalLength = 0
    for i = 1, #lengths do
        self.totalLength = self.totalLength + lengths[i]
    end
    self.parts = parts
    self.joints = {}
    self.root = vectors.vec3(0, 0, 0)
    self.target = vectors.vec3(0, 0, 0)
    self.autoPause = true
    self.name = name

    for i, part in ipairs(parts) do
        part:setParentType("WORLD")
        part:setPos(vectors.vec3(0, 0, 0) - part:getPivot())
        part:setPivot(0, 0, 0)
        if not models.ik then
            _ = models:newPart("ik")
        end
        if not models.ik[name] then
            _ = models.ik:newPart(name)
        end
        part:moveTo(models.ik[name])
        for _, child in ipairs(part:getChildren()) do
            child:setPos(vectors.vec3(0, 0, 0) - child:getPivot())
            child:setPivot(0, 0, 0)
        end
    end

    for i = 1, #parts + 1 do
        self.joints[i] = vectors.vec3(0, 0, 0)
    end

    return self
end

--- Performs a backward pass.
---
--- This shouldn't have to be called manually except in special cases.
--- @param target Vector3
function IKChain:backward(target)
    self.joints[#self.joints] = target

    for i = #self.joints - 1, 1, -1 do
        local r = (self.joints[i + 1] - self.joints[i])
        local l = self.lengths[i] / r:length()

        local pos = (1 - l) * self.joints[i + 1] + l * self.joints[i]
        self.joints[i] = pos
    end
end

--- Performs a forward pass.
---
--- This shouldn't have to be called manually except in special cases.
--- @param root Vector3
function IKChain:forward(root)
    self.joints[1] = root

    for i = 1, #self.joints - 1 do
        local r = (self.joints[i + 1] - self.joints[i])
        local l = self.lengths[i] / r:length()

        local pos = (1 - l) * self.joints[i] + l * self.joints[i + 1]
        self.joints[i + 1] = pos
    end
end

--- Solves the chain.
---
--- If `Chain.autoPause` is `true`, it will only solve if the target is in reach.
--- This is for performance reasons.
--- @param root Vector3
--- @param target Vector3
--- @param iterations number
function IKChain:solve(root, target, iterations)
    self.root = root
    self.target = target


    if self.autoPause and not self:isInReach() then
        return
    end


    for i = 1, iterations do
        self:backward(target * 16)
        self:forward(root * 16)
    end


    for i = 1, #self.lengths do
        local dir = self.joints[i + 1] - self.joints[i]
        local pos = self.joints[i] + dir:normalized() * self.lengths[i] / 2

        self.parts[i]:setPos(pos)
        self.parts[i]:setRot(dirToAngle(dir):add(vectors.vec3(90, 0, 0)):mul(vectors.vec3(-1, 1, 1)))
    end
end

--- Checks if a given position is in reach.
---
--- If `pos` is `nil`, it will use the IKChain's current target.
--- @param pos? Vector3
--- @return boolean
function IKChain:isInReach(pos)
    if pos == nil then
        pos = self.target
    end
    local dist = (self.root - pos):length()
    if dist * 16 > self.totalLength + #self.lengths then
        return false
    end
    return true
end

return IKChain
