local Workspace = game:GetService("Workspace")
local folder = Workspace:FindFirstChild("_Gizmos")

local cube = {}

function cube.update(instances, params)
	local cframe = params.cframe
	local size = params.size

	local cubeInstance = instances.cube

	cubeInstance.Size = size
	cubeInstance.CFrame = cframe
end

function cube.create()
	local cubeInstance = Instance.new("BoxHandleAdornment")
	cubeInstance.Name = "cube"
	cubeInstance.Adornee = Workspace
	cubeInstance.Parent = folder

	return {
		cube = cubeInstance,
	}
end

return cube