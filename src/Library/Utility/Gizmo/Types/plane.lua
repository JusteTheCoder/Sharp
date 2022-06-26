local Workspace = game:GetService("Workspace")
local folder = Workspace:FindFirstChild("_Gizmos")

local plane = {}

function plane.update(instances, params)
	local size = params.size
	local position = params.position
	local normal = params.normal

	local cube = instances.cube

	local right = normal:Cross(Vector3.zAxis)

	cube.Size = size
	cube.CFrame = CFrame.fromMatrix(position, right, normal):Orthonormalize()
end

function plane.create()
	local cube = Instance.new("BoxHandleAdornment")
	cube.Name = "cube"
	cube.Adornee = Workspace
	cube.Parent = folder

	return {
		cube = cube,
	}
end

return plane