--[=[
    Loads modules from the given locations.

    @private
    @class Loader
]=]

--[=[
    @private
    @within Loader
    @param location Instance
    @param t {string: [ModuleScript]}?
    @return {string: [ModuleScript]}
]=]

local function getRecursive(location, t)
	t = t or {}

	for _, child in ipairs(location:GetChildren()) do
		if child:IsA("ModuleScript") then
			t[child.Name] = child
		else
			getRecursive(child, t)
		end
	end

	return t
end

--[=[
	@private
	@within Package
	@param locations {Instance}
	@return {string: [ModuleScript]}
]=]

local function getAllRecursive(locations)
	local t = {}

	for _, location in ipairs(locations) do
		getRecursive(location, t)
	end

	return t
end

--[=[
    @private
    @within Loader
    @param location Instance
    @return {string: [ModuleScript]}
]=]

local function getDescendentModules(location)
	local t = {}

	for _, descendent in location:GetDescendants() do
		if descendent:IsA("ModuleScript") then
			t[descendent.Name] = descendent
		end
	end

	return t
end

return {
	getRecursive = getRecursive,
	getAllRecursive = getAllRecursive,
	getDescendentModules = getDescendentModules,
}
