

--[[
  _____     _     _     ___ _  __
 |__  /___ (_) __| |___|_ _| |/ /
   / // _ \| |/ _` / __|| || ' / 
  / /| (_) | | (_| \__ \| || . \ 
 /____\___/|_|\__,_|___/___|_|\_\                             
--]]

-- Zoid's IK implementation
-- https://github.com/TheZoidMaster/FiguraLibs/tree/main/ZoidsIK



local ZoidsIK = {}



-- Simple utility function to convert a direction vector to an angle vector
local function dirToAngle(dir)
    return vec(math.deg(math.atan2(dir.y, math.sqrt(dir.x * dir.x + dir.z * dir.z))), math.deg(math.atan2(dir.x, dir.z)), 0)
end


-- Chain class
ZoidsIK.Chain = {
    parts = {},
    lengths = {}
}


-- Chain constructor
function ZoidsIK.Chain.new(parts, lengths)
    local self = {}
    setmetatable(self, ZoidsIK.Chain)
    self.lengths = lengths
    self.totalLength = 0
    for i = 1, #lengths do
        self.totalLength = self.totalLength + lengths[i]
    end
    self.parts = parts
    self.rotation = vectors.vec3(90,0,0)
    self.rotationMultiplier = vectors.vec3(-1,1,1)
    self.joints = {}
    self.root = vectors.vec3(0,0,0)
    self.target = vectors.vec3(0,0,0)
    self.autoPause = true

    -- Setup parts for proper positioning
    for i, part in ipairs(parts) do
        part:setParentType("WORLD")
        part:setPos(vectors.vec3(0,0,0) - part:getPivot())
        part:setPivot(0,0,0)
        if not models.ik_chain then
            _ = models:newPart("ik_chain")
        end
        part:moveTo(models.ik_chain)
        for _, child in ipairs(part:getChildren()) do
            child:setPos(vectors.vec3(0,0,0) - child:getPivot())
            child:setPivot(0,0,0)
        end
    end

    -- Create joints
    for i = 1, #parts + 1 do
        self.joints[i] = vectors.vec3(0,0,0)
    end

    return self
end


-- Backward pass
function ZoidsIK.Chain:backward(target)
    -- Idk entirely how this works but it does so ¯\_(ツ)_/¯
    self.joints[#self.joints] = target

    for i = #self.joints -1, 1, -1 do
        local r = (self.joints[i + 1] - self.joints[i])
        local l = self.lengths[i] / r:length()

        local pos = (1 - l) * self.joints[i + 1] + l * self.joints[i]
        self.joints[i] = pos
    end
end


-- Forward pass
function ZoidsIK.Chain:forward(root)
    -- Idk entirely how this works but it does so ¯\_(ツ)_/¯
    self.joints[1] = root

    for i = 1, #self.joints - 1 do
        local r = (self.joints[i + 1] - self.joints[i])
        local l = self.lengths[i] / r:length()

        local pos = (1 - l) * self.joints[i] + l * self.joints[i + 1]
        self.joints[i + 1] = pos
    end
end


-- Solve chain
function ZoidsIK.Chain:solve(root, target, iterations)
    self.root = root
    self.target = target

    -- If autoPause is enabled, don't solve if not in reach
    -- This is for performance reasons and can be disabled
    if self.autoPause and not self:isInReach() then
        return
    end

    -- Perform forward and backward passes for specified number of iterations
    for i = 1, iterations do
        self:backward(target*16)
        self:forward(root*16)
    end


    -- Set positions and rotations of segments
    for i = 1, #self.lengths do
        local dir = self.joints[i + 1] - self.joints[i]
        local pos = self.joints[i] + dir:normalized() * self.lengths[i]/2

        self.parts[i]:setPos(pos)
        self.parts[i]:setRot(dirToAngle(dir):add(self.rotation):mul(self.rotationMultiplier))
    end
end


-- Check if target is in reach
function ZoidsIK.Chain:isInReach(pos)
    if pos == nil then
        pos = self.target
    end
    local dist = (self.root - pos):length()
    if dist > self.totalLength/16 then
        return false
    end
    return true
end

function ZoidsIK.Chain.__index(t, k)
    return ZoidsIK.Chain[k]
end

return ZoidsIK