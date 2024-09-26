# Zoid's IK

A simple but powerful FABRIK implementation, designed for ease of use.

Forgive me if I've made a mistake in the documentation or the code, this is my first Figura library.

# Docs

## Chain Class

The chain class is used to create an IK chain. It must be created with 3 parameters. `parts` is an array of the Modelparts you wish to include in the chain. `lengths` is an array of the length of each part in the chain in blockbench units. `name` is the name of the chain (used for sorting the modelparts).

Example:

```lua
local chain = Chain({
    parts = {
        models.model.segment1,
        models.model.segment2,
        models.model.segment3
    },
    lengths = {10, 7, 5},
    name = "example"
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
    lengths = {10, 7, 5},
    name = "example"
})
```

> [!IMPORTANT]  
> In the model, the cubes/meshes should be oriented long way up. It does not matter which way the group is facing. Faliure to do so will result in inaccurate IK results.

## Variables

Chains have 1 variable that can be modified:

`autoPause` - If true, the chain will not solve if the target is out of range. This is useful for chains that are constantly moving. Default is true.

## Methods

`Chain:solve(root, target, iterations)` - Solves the chain. `root` is the world coordinates of the root of the chain. `target` is the world coordinates of the target of the chain. `iterations` is the number of iterations.

`Chain:backward()` - Performs a backward pass on the chain. Shouldn't be called manually except for special cases.

`Chain:forward()` - Performs a forward pass on the chain. Shouldn't be called manually except for special cases.

`Chain:isInRange(pos?)` - Returns true if the chain is in range of the target. If pos is not provided, it will check if the current target position is in range instead.

# Usage

## Code Example:

```lua
local Chain = require("ZoidsIK")

local chain = Chain({
    parts = {
        models.path.to.part1,
        models.path.to.part2,
        models.path.to.part3
    },
    lengths = {length1, length2, length3},
    name = "example"
})

function events.render()
    chain:solve(vectors.vec3(0, 0, 0), vectors.vec3(1, 1, 1), 5)
```

> [!TIP]  
> Modelparts added to a chain will be moved to `models.ik.<name>` (e.g. `models.ik.example` for the example above), so make sure to use that when referencing them after initializing the chain.

## Example Avatar:

Download [Example.zip](https://github.com/TheZoidMaster/FiguraLibs/blob/main/ZoidsIK/Example.zip) and put it in your avatar folder, then equip the avatar and place your playerhead. It will create an IK chain that follows the nearest entity.
