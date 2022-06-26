local Workspace = game:GetService("Workspace")
local folder = Workspace:FindFirstChild("_Gizmos")

local sphere = {}

function sphere.update(instances, params)
	local cframe = params.cframe
	local radius = params.radius

	local sphereInstance = instances.sphere

	sphereInstance.Radius = radius
	sphereInstance.CFrame = cframe
end

function sphere.create()
	local sphereInstance = Instance.new("SphereHandleAdornment")
	sphereInstance.Name = "sphere"
	sphereInstance.Adornee = Workspace
	sphereInstance.Parent = folder

	return {
		sphere = sphereInstance,
	}
end

return sphere
