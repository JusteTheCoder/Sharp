--[=[
	Provides functions for loading and searching for modules in Sharp.

	@private
	@class Package
]=]

--[=[
	An object for lazy loading of modules.
	@interface PackageObject
	@within Package
	._name string -- The name of the package.
	._modules {string: [ModuleScript]} -- The modules in the package.
	.__index (self: PackageObject, key: string) -> [ModuleScript]
]=]

local MODULE_NOT_FOUND = "Module by the name of '%s' was not found in the package '%s'."
local STRICT_WRITE_ERROR = "Cannot assign property '%s' to read-only table '%s'."

local Internal = script.Parent
local Logger = require(Internal.Utility.Logger)

local function _nextModule(t, lastName)
	local name, module = next(t, lastName)

	if module == nil then
		return nil
	end

	return name, require(module)
end

local packageMeta = {
	__index = function(self, key)
		local module = self._modules[key]
		return module and require(module) or Logger.error(2, MODULE_NOT_FOUND, key, self._name)
	end,

	__newindex = function(self, key)
		Logger.logError(2, STRICT_WRITE_ERROR, key, self._name)
	end,

	__iter = function(self)
		return _nextModule, self._modules
	end,
}

--[=[
	Builds a package given a dictionary of modules.

	@private
	@within Package
	@param moduleDictionary {string: [ModuleScript]}
	@param name string?

	@return PackageObject
]=]

local function buildPackage(moduleDictionary, name)
	return setmetatable({ _name = name or "Package", _modules = moduleDictionary }, packageMeta)
end

--[=[
	Searches for all modules in the specified location.

	@private
	@within Package
	@param location Instance
	@param t {string: [ModuleScript]}?

	@return {string: [ModuleScript]}
]=]

local function searchModuleTree(location, t)
	t = t or {}

	for _, child in location:GetChildren() do
		if child:IsA("ModuleScript") then
			t[child.Name] = child
		else
			searchModuleTree(child, t)
		end
	end

	return t
end

--[=[
	Searches for all modules in the specified locations.

	@private
	@within Package
	@param locations {Instance}

	@return {string: [ModuleScript]}
]=]

local function searchModuleTrees(locations)
	local t = {}

	for _, location in locations do
		searchModuleTree(location, t)
	end

	return t
end

--[[
	Gets all descendent modules of the specified location.

	@private
	@within Package
	@param location Instance

	@return {string: [ModuleScript]}, boolean -- The modules, and whether or not the location contains modules.
]]

local function getDescendentModules(location)
	local t = {}
	local hasModules = false

	for _, descendent in location:GetDescendants() do
		if descendent:IsA("ModuleScript") then
			t[descendent.Name] = descendent
			hasModules = true
		end
	end

	return t, hasModules
end

return table.freeze({
	buildPackage = buildPackage,
	searchModuleTree = searchModuleTree,
	searchModuleTrees = searchModuleTrees,
	getSubModules = getDescendentModules,
})
