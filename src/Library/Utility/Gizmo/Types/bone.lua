local BONE_HEIGHT_END = 4 / 5
local BONE_HEIGHT_START = 1 / 5
local BONE_RADIUS = 0.4 / 5
local BONE_HANDLE_RADIUS = 0.2 / 5

local Workspace = game:GetService("Workspace")
local folder = Workspace:FindFirstChild("_Gizmos")

local bone = {}

function bone.update(instances, params)
    local startPoint = params.startPoint
	local endPoint = params.endPoint

	local direction = endPoint - startPoint
	local length = direction.magnitude

	local originSphere = instances.originSphere
	local endSphere = instances.endSphere
	local originBone = instances.originBone
	local endBone = instances.endBone

	originSphere.Radius = BONE_HANDLE_RADIUS * length
	endSphere.Radius = BONE_HANDLE_RADIUS * length

	originBone.Radius = BONE_RADIUS * length
	endBone.Radius = BONE_RADIUS * length

	originBone.Height = BONE_HEIGHT_START * length
	endBone.Height = BONE_HEIGHT_END * length

	originSphere.CFrame = CFrame.new(startPoint)
	endSphere.CFrame = CFrame.new(endPoint)

	originBone.CFrame = CFrame.lookAt(endPoint, startPoint) * CFrame.new(0, 0, -length + originBone.Height)
	endBone.CFrame = CFrame.lookAt(startPoint, endPoint) * CFrame.new(0, 0, -originBone.Height)
end

function bone.create()
    local originSphere = Instance.new("SphereHandleAdornment")
	originSphere.Name = "originSphere"
	originSphere.Adornee = Workspace
	originSphere.Parent = folder

	local endSphere = Instance.new("SphereHandleAdornment")
	endSphere.Name = "endSphere"
	endSphere.Adornee = Workspace
	endSphere.Parent = folder

	local originBone = Instance.new("ConeHandleAdornment")
	originBone.Name = "originBone"
	originBone.Adornee = Workspace
	originBone.Parent = folder

	local endBone = Instance.new("ConeHandleAdornment")
	endBone.Name = "endBone"
	endBone.Adornee = Workspace
	endBone.Parent = folder

	return {
		originSphere = originSphere,
		endSphere = endSphere,
		originBone = originBone,
		endBone = endBone,
	}
end

return bone