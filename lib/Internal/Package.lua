--[=[
	@private
	@class Package
]=]

--[=[
	An object for lazy loading modules.
	@interface PackageObject
	@within Package
	._name string -- The name of the package.
	._modules {string: [ModuleScript]} -- The modules in the package.
	.__index (self: PackageObject, key: string) -> [ModuleScript]
]=]

--[=[
	Builds a package given a dictionary of modules.

	@private
	@within Package
	@param moduleDictionary {string: [ModuleScript]}
	@param name string?

	@return PackageObject
]=]

local Internal = script.Parent
local Util = Internal.Util

local TableUtil = require(Util.TableUtil)
local Loader = require(Internal.Loader)

local MODULE_NOT_FOUND = "Module by the name of '%s' was not found in the package '%s'."
local STRICT_WRITE_ERROR = "Cannot assign property '%s' to read-only table '%s'."

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
		return module and require(module) or error(MODULE_NOT_FOUND:format(key, self._name), 2)
	end,

	__newindex = function(self, key)
		error(STRICT_WRITE_ERROR:format(key, self._name), 2)
	end,

	__iter = function(self)
		return _nextModule, self._modules
	end,
}

--[=[
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
	Takes a table of modules and returns a dictionary of packages.
	Allows then access to sub-modules by indexing the package.

	@private
	@within Package
	@param modules {[ModuleScript]}

	@return {string: [Package.PackageObject]}
]=]

local function buildPackages(modules)
	local packages = {}

	for _, module in ipairs(modules) do
		local name = module.Name
		local subModules = Loader.getDescendentModules(module)
		-- Only build a package if the module has sub-modules.
		if TableUtil.Dictionary.isEmpty(subModules) then
			packages[name] = buildPackage(subModules, name)
		end
	end

	return packages
end

return {
	buildPackage = buildPackage,
	buildPackages = buildPackages,
}
