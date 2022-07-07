local Workspace = game:GetService("Workspace")
local folder = Workspace:FindFirstChild("_Gizmos")

local line = {}

function line.update(instances, params)
	local startPoint = params.startPoint
	local endPoint = params.endPoint
	local thickness = params.thickness

	local length = (endPoint - startPoint).Magnitude

	local cylinder = instances.cylinder

	cylinder.CFrame = CFrame.lookAt(startPoint, endPoint) * CFrame.new(0, 0, -length / 2)
	cylinder.Height = length
	cylinder.Radius = thickness
end

function line.create()
	local cylinder = Instance.new("CylinderHandleAdornment")
	cylinder.Name = "cylinder"
	cylinder.Adornee = Workspace
	cylinder.Parent = folder

	return {
		cylinder = cylinder,
	}
end

return line
