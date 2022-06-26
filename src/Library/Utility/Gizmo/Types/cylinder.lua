local Workspace = game:GetService("Workspace")
local folder = Workspace:FindFirstChild("_Gizmos")

local cylinder = {}

function cylinder.update(instances, params)
	local cframe = params.cframe
	local radius = params.radius
	local height = params.height

	local cylinderInstance = instances.cylinder

	cylinderInstance.Radius = radius
	cylinderInstance.Height = height
	cylinderInstance.CFrame = cframe
end

function cylinder.create()
	local cylinderInstance = Instance.new("CylinderHandleAdornment")
	cylinderInstance.Name = "cylinder"
	cylinderInstance.Adornee = Workspace
	cylinderInstance.Parent = folder

	return {
		cylinder = cylinderInstance,
	}
end

return cylinder