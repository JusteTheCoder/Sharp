--[=[
	Provides functions for constructing libraries.

	@private
	@class Library
]=]

local Internal = script.Parent
local Package = require(Internal.Package)

--[=[
	Takes a table of modules and returns a dictionary of packages.
	Allows then access to sub-modules by indexing the package.

	@private
	@within Library
	@param modules {[ModuleScript]}

	@return {string: [Package.PackageObject]}
]=]

local function buildPackages(modules)
	local packages = {}

	for _, module in modules do
		local name = module.Name
		local subModules, hasModules = Package.getDescendentModules(module)
		-- Only build a package if the module has sub-modules.
		if hasModules then
			packages[name] = Package.buildPackage(subModules, name)
		end
	end

	return packages
end

--[=[
	Builds a library given locations.

	@private
	@within Library
	@param locations {[Instance]}

	@return [Package.PackageObject]
]=]

local function buildLibrary(locations)
	local modules = Package.searchModuleTrees(locations)
	local library = Package.buildPackage(modules, "Library")

	return library
end

return table.freeze({
	buildLibrary = buildLibrary,
	buildPackages = buildPackages
})