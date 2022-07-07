local Sharp = _G.Sharp

local TableUtil = Sharp.Library.TableUtil

local UPDATE_INTERVAL = 1 / 4

local folder = Instance.new("Folder")
folder.Name = "_Gizmos"
folder.Parent = workspace

--[=[
	A powerful tool for visualizing data in 3D space.
	Not intended for use in production, but rather as a debugging tool.

	@class Gizmo
]=]

local Gizmo = {
	_types = {},
	_references = TableUtil.Meta.weakKeys({}),

	_settings = {
		color = Color3.new(1, 1, 1),
		transparency = 0.5,
		alwaysOnTop = true,
		zIndex = 1,
	},
}

--[=[
	Sets a property of the gizmo.

	@private
	@param instances {...: Instance}
	@param property string
	@param value any
]=]

function Gizmo._setProperty(instances, property, value)
	for _, instance in instances do
		instance[property] = value
	end
end

--[=[
	Creates a new gizmo.

	@param type string
	@param params {...: any}
	@param reference any?

	@return Gizmo
]=]

function Gizmo.use(type, params, reference)
	if not reference then
		local source, line = debug.info(2, "sl")
		reference = source .. ":" .. line
	end

	local gizmoType = Gizmo._types[type]
	assert(gizmoType, "Gizmo type '" .. type .. "' does not exist.")

	local gizmo = Gizmo._references[reference]
	if not gizmo then
		gizmo = {
			updated = true,
			params = params,
			instances = gizmoType.create(params),
		}
		Gizmo._references[reference] = gizmo
	else
		gizmo.updated = true
		TableUtil.Dictionary.fill(gizmo.params, params)
	end

	gizmoType.update(gizmo.instances, gizmo.params)

	Gizmo._setProperty(gizmo.instances, "Color", Gizmo._settings.color)
	Gizmo._setProperty(gizmo.instances, "Transparency", Gizmo._settings.transparency)
	Gizmo._setProperty(gizmo.instances, "AlwaysOnTop", Gizmo._settings.alwaysOnTop)
	Gizmo._setProperty(gizmo.instances, "ZIndex", Gizmo._settings.zIndex)
end

--[=[
	Set the color of a gizmo.

	@param color Color3
]=]

function Gizmo.useColor(color)
	Gizmo._settings.color = color
end

--[=[
	Set the transparency of a gizmo.

	@param transparency number
]=]

function Gizmo.useTransparency(transparency)
	Gizmo._settings.transparency = transparency
end

--[=[
	Set the always-on-top property of a gizmo.

	@param alwaysOnTop boolean
]=]

function Gizmo.useAlwaysOnTop(onTop)
	Gizmo._settings.alwaysOnTop = onTop
end

--[=[
	Set the z-index of a gizmo.

	@param zIndex number
]=]

function Gizmo.useZIndex(zIndex)
	Gizmo._settings.zIndex = zIndex
end

--[=[
	Destroy a gizmo.

	@param reference any
]=]

function Gizmo.destroy(reference)
	local gizmo = Gizmo._references[reference]

	if gizmo then
		for _, instance in gizmo.instances do
			instance:Destroy()
		end
		Gizmo._references[reference] = nil
	end
end

--[=[
	Destroy all gizmos.
]=]

function Gizmo.clear()
	for reference in Gizmo._references do
		Gizmo.destroy(reference)
	end

	table.clear(Gizmo._references)
end

--[=[
	Initializes the gizmo library.

	@private
]=]

function Gizmo.start()
	for name, gizmoType in Sharp.package.Gizmo do
		Gizmo._types[name] = gizmoType
	end

	task.spawn(function()
		while task.wait(UPDATE_INTERVAL) do
			for reference, gizmo in Gizmo._references do
				if gizmo.updated then
					gizmo.updated = false
					continue
				end

				Gizmo.destroy(reference)
			end
		end
	end)

	return table.freeze(Gizmo)
end

return Gizmo.start()
