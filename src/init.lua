--[=[
	The main file for the Sharp framework.

	@class Sharp
]=]

local Internal = script.Internal
local Package = require(Internal.Package)
local Library = require(Internal.Library)
local Singleton = require(Internal.Singleton)
local Table = require(Internal.Utility.Table)
local Promise = require(Internal.Utility.Promise)

local Sharp = {
	_loadedSingletons = {},
	_singletons = {},
	_libraries = {
		script.Library,
		Internal.Utility,
	},
}

local function readyPackages()
	local modules = Package.searchModuleTrees(Table.array.merge(Sharp._libraries, Sharp._singletons))
	Sharp.package = Library.buildPackages(modules)
end

local function readyLibrary()
	Sharp.library = Library.buildLibrary(Sharp._libraries)
end

local function prepareSingleton()
	Sharp.singleton = Singleton

	for _, module in Package.searchModuleTrees(Sharp._singletons) do
		Sharp._loadedSingletons[module.Name] = require(module)
	end
end

local function readySingleton()
	return Promise.new(function(resolve)
		local initPromises = {}

		for singletonName, singleton in Sharp._loadedSingletons do
			if type(singleton.init) ~= "function" then
				continue
			end

			table.insert(
				initPromises,
				Promise.new(function(r)
					debug.setmemorycategory(singletonName)
					singleton.init()
					r()
				end)
			)
		end

		resolve(Promise.all(initPromises))
	end):andThen(function()
		for singletonName, singleton in Sharp._loadedSingletons do
			if type(singleton.start) ~= "function" then
				continue
			end

			task.spawn(function()
				debug.setmemorycategory(singletonName)
				singleton.start()
			end)
		end
	end)
end

--[=[
	Register a new location for singletons.

	:::info

	This function must be called before the Sharp framework is initialized.

	:::

	@param location Instance
	@return Sharp
]=]

function Sharp.registerSingleton(location)
	table.insert(Sharp._singletons, location)
	return Sharp
end

--[=[
	Register a new location for libraries.

	:::info

	This function must be called before the Sharp framework is initialized.

	:::

	@param location Instance
	@return Sharp
]=]

function Sharp.registerLibrary(location)
	table.insert(Sharp._libraries, location)
	return Sharp
end

--[=[
	Initialize the Sharp framework.
	Returns a Promise that resolves when the framework is ready.

	@return [Promise]
]=]

function Sharp.start()
	_G.Sharp = Sharp

	readyPackages()
	readyLibrary()
	prepareSingleton()

	return readySingleton():andThen(function()
		Singleton.endRunCycle()
	end)
end

table.freeze(Sharp)
return Sharp
