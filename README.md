# rbx-instance-serializer

Transforms roblox instances 🙀

## Supported builders

### Vanilla

> Uses Instance.new()

<details>
<summary>Sample</summary>

```luau
local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Locked = true
baseplate.Anchored = true
baseplate.Size = Vector3.new(512, 20, 512)
baseplate.BottomSurface = Enum.SurfaceType.Smooth
baseplate.TopSurface = Enum.SurfaceType.Smooth
baseplate.Color = Color3.fromRGB(98, 94, 98)
baseplate.CFrame = CFrame.new(Vector3.yAxis * -10) * CFrame.fromEulerAnglesXYZ(0, math.rad(10), 0)
do
    local texture = Instance.new("Texture")
    texture.Texture = "rbxassetid://6372755229"
    texture.StudsPerTileV = 8
    texture.StudsPerTileU = 8
    texture.Transparency = 0.8
    texture.Face = Enum.NormalId.Top
    texture.Color3 = Color3.fromRGB(0, 0, 0)
    texture.Parent = baseplate
end
```

</details>

### Types

> Transforms instances into Luau types

<details>
<summary>Sample</summary>

```luau
export type Baseplate = Part & {
    Texture: Texture,
}
```

</details>

### React

> Transforms instances into react lua elements

<details>
<summary>Sample</summary>

```luau
local react = nil -- provide react lib here
local e = react.createElement

local baseplate = e("Part", {
	Locked = true,
	Anchored = true,
	Size = Vector3.new(512, 20, 512),
	BottomSurface = Enum.SurfaceType.Smooth,
	TopSurface = Enum.SurfaceType.Smooth,
	Color = Color3.fromRGB(98, 94, 98),
	CFrame = CFrame.new(Vector3.yAxis * -10) * CFrame.fromEulerAnglesXYZ(0, math.rad(10), 0),
}, {
	Texture = e("Texture", {
		Texture = "rbxassetid://6372755229",
		StudsPerTileV = 8,
		StudsPerTileU = 8,
		Transparency = 0.8,
		Face = Enum.NormalId.Top,
		Color3 = Color3.fromRGB(0, 0, 0),
	}),
})
```

</details>

## TODO

- [x] add React builder
- [x] `datatype.luau` plugin settings
- [x] `properties.luau` plugin settings

## License

[view here](./LICENSE)

```

```
