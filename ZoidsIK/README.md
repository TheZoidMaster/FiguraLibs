# Zoid's IK
A simple FABRIK implementation, designed for ease of use.

Forgive me if I've made a mistake in the documentation or the code, this is my first Figura library.

# Docs
## Chain Class
The chain class is used to create an IK chain. It must be created with 2 parameters. `parts` is an array of the Modelparts you wish to include in the chain. `lengths` is an array of the length of each part in the chain in blockbench units.

Example:
```lua
local chain = ZoidsIK.Chain({
    parts = {
        models.model.segment1,
        models.model.segment2,
        models.model.segment3
    },
    lengths = {10, 7, 5}
})
```
The chain can also be initialized with nested parts.

Example:
```lua
local chain = ZoidsIK.Chain({
    parts = {
        models.model.segment1,
        models.model.segment1.segment2,
        models.model.segment1.segment2.segment3
    },
    lengths = {10, 7, 5}
})
```

## Variables
Chains have 3 variables that can be modified:

`rotation` - The rotation of each segment in the chain as a vector. (used for creating chains pointed in a direction other than up or down in the model — not recommended for now)

`rotationMultiplier` - The multiplier for the rotation of each segment in the chain. (used for creating chains pointed in a direction other than up or down in the model — not recommended for now)

`autoPause` - If true, the chain will not solve if the target is out of range.

## Methods

`Chain:solve(root, target, iterations)` - Solves the chain. `root` is the world coordinates of the root of the chain. `target` is the world coordinates of the target of the chain. `iterations` is the number of iterations.

`Chain:backward()` - Performs a backward pass on the chain.

`Chain:forward()` - Performs a forward pass on the chain.

`Chain:isInRange(pos)` - Returns true if the chain is in range of the target. If pos is nil, it will check if the current target position is in range instead.

# Usage
## Code Example:
```lua
local ik = require("ZoidsIK")

local chain = ik.Chain({
    parts = {
        models.path.to.part1,
        models.path.to.part2,
        models.path.to.part3
    },
    lengths = {length1, length2, length3}
})

function events.render()
    chain:solve(vectors.vec3(0, 0, 0), vectors.vec3(0, 0, 0), 5)
```
## Avatar Example:
Download [Example.zip](https://github.com/TheZoidMaster/FiguraLibs/blob/main/ZoidsIK/Example.zip) and put it in your avatar folder, then equip the avatar and place your playerhead. It will create an IK chain that follows the nearest entity.