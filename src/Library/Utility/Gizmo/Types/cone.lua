local Workspace = game:GetService("Workspace")
local folder = Workspace:FindFirstChild("_Gizmos")

local cone = {}

function cone.update(instances, params)
	local coneInstance = instances.cone

	local startPoint = params.startPoint
	local direction = params.direction
	local angle = params.angle * 0.5

	local length = math.cos(angle) * direction.Magnitude
	local radius = math.sin(angle) * direction.Magnitude

	coneInstance.Radius = radius
	coneInstance.Height = length
	coneInstance.CFrame = CFrame.lookAt(startPoint + direction.Unit * length, startPoint)
end

function cone.create()
	local coneInstance = Instance.new("ConeHandleAdornment")
	coneInstance.Name = "cone"
	coneInstance.Adornee = Workspace
	coneInstance.Parent = folder

	return {
		cone = coneInstance,
	}
end

return cone