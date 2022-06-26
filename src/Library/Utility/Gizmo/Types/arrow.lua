local ARROW_CYLINDER_RADIUS = 0.1
local ARROW_CONE_HEIGHT = 1
local ARROW_CONE_RADIUS = 0.5

local Workspace = game:GetService("Workspace")
local folder = Workspace:FindFirstChild("_Gizmos")

local arrow = {}

function arrow.update(instances, params)
	local startPoint = params.startPoint
	local endPoint = params.endPoint

	local direction = endPoint - startPoint
	local length = direction.magnitude

	local cone = instances.cone
	local cylinder = instances.cylinder

	cone.Radius = ARROW_CONE_RADIUS
	cone.Height = ARROW_CONE_HEIGHT

	cylinder.Radius = ARROW_CYLINDER_RADIUS
	cylinder.Height = length - ARROW_CONE_HEIGHT

	cone.CFrame = CFrame.lookAt(startPoint, endPoint) * CFrame.new(0, 0, -length + ARROW_CONE_HEIGHT)
	cylinder.CFrame = CFrame.lookAt(startPoint, endPoint) * CFrame.new(0, 0, (-length + ARROW_CONE_HEIGHT) / 2)
end

function arrow.create()
	local cone = Instance.new("ConeHandleAdornment")
	cone.Name = "cone"
	cone.Adornee = Workspace
	cone.Parent = folder

	local cylinder = Instance.new("CylinderHandleAdornment")
	cylinder.Name = "cylinder"
	cylinder.Adornee = Workspace
	cylinder.Parent = folder

	return {
		cone = cone,
		cylinder = cylinder,
	}
end

return arrow