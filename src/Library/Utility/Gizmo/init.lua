local Sharp = _G.Sharp

--[=[
	A powerful tool for visualizing data in 3D space.
	Not intended for use in production, but rather as a debugging tool.

	@class Gizmo
]=]

local BONE_HEIGHT_END = 4 / 5
local BONE_HEIGHT_START = 1 / 5
local BONE_RADIUS = 0.4 / 5
local BONE_HANDLE_RADIUS = 0.2 / 5

local ARROW_CYLINDER_RADIUS = 0.1
local ARROW_CONE_HEIGHT = 1
local ARROW_CONE_RADIUS = 0.5

local Table = Sharp.library.Table

local Workspace = game:GetService("Workspace")

local folder = Instance.new("Folder")
folder.Name = "Gizmos"
folder.Parent = Workspace

local Gizmo = {
	types = {
		bone = "bone",
		arrow = "arrow",
		sphere = "sphere",
		cube = "cube",
		cylinder = "cylinder",
		line = "line",
		cone = "cone",
		plane = "plane",
	},

	settings = {
		color = Color3.new(1, 1, 1),
		transparency = 0.5,
		alwaysOnTop = true,
		zIndex = 1,
	},

	_gizmos = {},
}

local updates = {}

function updates.bone(gizmo, params)
	local startPoint = params.startPoint
	local endPoint = params.endPoint

	local direction = endPoint - startPoint
	local length = direction.magnitude

	local originSphere = gizmo.components.originSphere
	local endSphere = gizmo.components.endSphere
	local originBone = gizmo.components.originBone
	local endBone = gizmo.components.endBone

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

function updates.arrow(gizmo, params)
	local startPoint = params.startPoint
	local endPoint = params.endPoint

	local direction = endPoint - startPoint
	local length = direction.magnitude

	local cone = gizmo._components.cone
	local cylinder = gizmo._components.cylinder

	cone.Radius = ARROW_CONE_RADIUS
	cone.Height = ARROW_CONE_HEIGHT

	cylinder.Radius = ARROW_CYLINDER_RADIUS
	cylinder.Height = length - ARROW_CONE_HEIGHT

	cone.CFrame = CFrame.lookAt(startPoint, endPoint) * CFrame.new(0, 0, -length + ARROW_CONE_HEIGHT)
	cylinder.CFrame = CFrame.lookAt(startPoint, endPoint) * CFrame.new(0, 0, (-length + ARROW_CONE_HEIGHT) / 2)
end

function updates.sphere(gizmo, params)
	local cframe = params.cframe
	local radius = params.radius

	local sphere = gizmo._components.sphere

	sphere.Radius = radius
	sphere.CFrame = cframe
end

function updates.cube(gizmo, params)
	local cframe = params.cframe
	local size = params.size

	local cube = gizmo._components.cube

	cube.Size = size
	cube.CFrame = cframe
end

function updates.cylinder(gizmo, params)
	local cframe = params.cframe
	local radius = params.radius
	local height = params.height

	local cylinder = gizmo._components.cylinder

	cylinder.Radius = radius
	cylinder.Height = height
	cylinder.CFrame = cframe
end

function updates.line(gizmo, params)
	local startPoint = params.startPoint
	local endPoint = params.endPoint
	local thickness = params.thickness

	local length = (endPoint - startPoint).Magnitude

	local line = gizmo._components.cylinder

	line.CFrame = CFrame.lookAt(startPoint, endPoint) * CFrame.new(0, 0, -length / 2)
	line.Height = length
	line.Radius = thickness
end

function updates.cone(gizmo, params)
	local cone = gizmo._components.cone

	local startPoint = params.startPoint
	local direction = params.direction
	local angle = params.angle * 0.5

	local length = math.cos(angle) * direction.Magnitude
	local radius = math.sin(angle) * direction.Magnitude

	cone.Radius = radius
	cone.Height = length
	cone.CFrame = CFrame.lookAt(startPoint + direction.Unit * length, startPoint)
end

function updates.plane(gizmo, params)
	local size = params.size
	local position = params.position
	local normal = params.normal

	local plane = gizmo._components.cube

	local right = normal:Cross(Vector3.zAxis)

	plane.Size = size
	plane.CFrame = CFrame.fromMatrix(position, right, normal):Orthonormalize()
end

local componentCreations = {}

function componentCreations.bone()
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

function componentCreations.arrow()
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

function componentCreations.sphere(params)
		local sphere = Instance.new("SphereHandleAdornment")
		sphere.Name = "sphere"
		sphere.Adornee = Workspace
		sphere.Parent = folder

		sphere.Radius = params.radius or 1

		return {
			sphere = sphere,
		}
end

function componentCreations.cube(params)
	local cube = Instance.new("BoxHandleAdornment")
	cube.Name = "cube"
	cube.Adornee = Workspace
	cube.Parent = folder

	return {
		cube = cube,
	}
end

function componentCreations.cylinder()
	local cylinder = Instance.new("CylinderHandleAdornment")
	cylinder.Name = "cylinder"
	cylinder.Adornee = Workspace
	cylinder.Parent = folder

	return {
		cylinder = cylinder,
	}
end

function componentCreations.line(params)
	local cylinder = Instance.new("CylinderHandleAdornment")
	cylinder.Name = "cylinder"
	cylinder.Adornee = Workspace
	cylinder.Parent = folder

	return {
		cylinder = cylinder,
	}
end

function componentCreations.cone(params)
	local cone = Instance.new("ConeHandleAdornment")
	cone.Name = "cone"
	cone.Adornee = Workspace
	cone.Parent = folder

	return {
		cone = cone,
	}
end

function componentCreations.plane()
	local cube = Instance.new("BoxHandleAdornment")
	cube.Name = "cube"
	cube.Adornee = Workspace
	cube.Parent = folder

	return {
		cube = cube,
	}
end

--[=[
	Creates a new gizmo.

	@param type string
	@param params {...: any}

	@return Gizmo
]=]

function Gizmo.create(type, params)
	local gizmo = {
		_type = type,
		_components = componentCreations[type](),
		_lastParams = params,
	}

	Gizmo.setParams(gizmo, params)
	Gizmo.setColor(gizmo)
	Gizmo.setAlpha(gizmo)

	table.insert(Gizmo._gizmos, gizmo)

	return gizmo
end

--[=[
	Update the gizmo

	@param gizmo Gizmo
	@param params {...: any}
]=]

function Gizmo.setParams(gizmo, params)
	Table.dictionary.fill(params, gizmo._lastParams)

	gizmo._lastParams = params
	updates[gizmo._type](gizmo, params)
end

--[=[
	Sets the color of a gizmo.

	@param gizmo Gizmo
	@param color Color3
]=]

function Gizmo.setColor(gizmo, color)
	color = color or Gizmo.settings.color

	for _, component in pairs(gizmo._components) do
		component.Color3 = color
	end
end

--[=[
	Set the transparency of a gizmo.

	@param gizmo Gizmo
	@param alpha number
]=]

function Gizmo.setAlpha(gizmo, alpha)
	alpha = alpha or Gizmo.settings.transparency

	for _, component in pairs(gizmo._components) do
		component.Transparency = alpha
	end
end

--[=[
	Destroy a gizmo.

	@param gizmo Gizmo
]=]

function Gizmo.destroy(gizmo)
	for _, component in pairs(gizmo._components) do
		component:Destroy()
	end

	table.remove(Gizmo._gizmos, table.find(Gizmo._gizmos, gizmo))
end

--[=[
	Set the alwaysOnTop of a gizmo.

	@param gizmo Gizmo
	@param alwaysOnTop boolean
]=]

function Gizmo.setAlwaysOnTop(gizmo, alwaysOnTop)
	alwaysOnTop = if alwaysOnTop ~= nil then alwaysOnTop else Gizmo.settings.alwaysOnTop

	for _, component in pairs(gizmo._components) do
		component.AlwaysOnTop = alwaysOnTop
	end
end

--[=[
	Destroys all gizmos.
]=]

function Gizmo.clear()
	for _, gizmo in pairs(Gizmo._gizmos) do
		for _, component in pairs(gizmo._components) do
			component:Destroy()
		end
	end

	table.clear(Gizmo._gizmos)
end

--[=[
	Sets the visibility of all gizmos.

	@param visible boolean
]=]

function Gizmo.setVisible(visible)
	for _, gizmo in pairs(Gizmo._gizmos) do
		for _, component in pairs(gizmo._components) do
			component.Visible = visible
		end
	end
end

table.freeze(Gizmo)
return Gizmo