local SourceLibrary = script.Library
local Internal = script.Internal
local Util = Internal.Util

local Loader = require(Internal.Loader)
local Package = require(Internal.Package)
local Singleton = require(Internal.Singleton)

local Symbol = require(Util.Symbol)
local TableUtil = require(Util.TableUtil)

local ADD_LIBRARY_ERROR = "Attempted to add library location '%s' after startup."
local ADD_SINGLETON_ERROR = "Attempted to add singleton location '%s' after startup."
local DUPLICATE_LIBRARY_ERROR = "Attempted to add library location '%s' twice."
local DUPLICATE_SINGLETON_ERROR = "Attempted to add singleton location '%s' twice."
local ALREADY_STARTED_ERROR = "Attempted to start Sharp after it has already been started."

local started = Symbol("started")
local ready = Symbol("ready")
local awaiting = Symbol("awaiting")

local singletons = Symbol("singletons")
local libraries = Symbol("libraries")
local awaitingSingletons = Symbol("awaitingSingletons")

--[=[
    Sharp is a lightweight framework that focuses on code
    organization and structure while also offering a solution
    for seamlessly bridging the server-client barrier.

    @class Sharp
]=]

local Sharp = {
	[started] = false,
	[ready] = false,
	[awaiting] = {},

	[singletons] = {},
	[awaitingSingletons] = {},
	[libraries] = { SourceLibrary, Util },

	Singleton = Singleton,
	Library = nil,
	Package = nil,
}

local function preparePackage()
	local modules = Loader.getAllRecursive(TableUtil.Array.merge(Sharp[libraries], Sharp[singletons]))
	Sharp.Package = Package.buildPackages(modules)
end

local function prepareLibrary()
	local modules = Loader.getAllRecursive(Sharp[libraries])
	Sharp.Library = Package.buildPackage(modules, "Library")
end

local function prepareSingleton()
	local modules = Loader.getAllRecursive(Sharp[singletons])

	for name, module in modules do
		Sharp[awaitingSingletons][name] = require(module)
	end
end

local function startSingletonLifeCycle()
	local thread = coroutine.running()

	local size = 0
	local finished = 0

	for name, singleton in Sharp[awaitingSingletons] do
		if type(singleton.first) ~= "function" then
			continue
		end

		size += 1

		task.spawn(function()
			debug.setmemorycategory(name)
			singleton.first()
			finished += 1

			if finished == size and coroutine.status(thread) == "suspended" then
				task.spawn(thread)
			end
		end)
	end

	if size ~= finished then
		coroutine.yield()
	end

	for name, singleton in Sharp[awaitingSingletons] do
		if type(singleton.on) ~= "function" then
			continue
		end

		task.spawn(function()
			debug.setmemorycategory(name)
			singleton.on()
		end)
	end

	Singleton._onLifeCycleComplete()
end

local function releaseAwaiting()
	for _, awaitingThread in ipairs(Sharp[awaiting]) do
		task.defer(awaitingThread)
	end
end

--[=[
    Adds a location for libraries to be loaded from.

    :::info

	This function must be called before the Sharp is started.

	:::

    @param location Instance
    @return Sharp
]=]

function Sharp.addLibraries(location)
	if Sharp[started] then
		warn(ADD_LIBRARY_ERROR:format(tostring(location)))
	end

	if table.find(Sharp[libraries], location) then
		warn(DUPLICATE_LIBRARY_ERROR:format(tostring(location)))
	end

	table.insert(Sharp[libraries], location)
end

--[=[
    Adds a location for singletons to be loaded from.

    :::info

	This function must be called before the Sharp is started.

	:::

    @param location Instance
    @return Sharp
]=]

function Sharp.addSingletons(location)
	if Sharp[started] then
		warn(ADD_SINGLETON_ERROR:format(tostring(location)))
	end

	if table.find(Sharp[singletons], location) then
		warn(DUPLICATE_SINGLETON_ERROR:format(tostring(location)))
	end

	table.insert(Sharp[singletons], location)
end

--[=[
    Starts the Sharp lifecycle and loads all libraries and singletons.

    :::info

	If none of the singletons yield on initialization this function
    will return immediately.

	:::

    @yields
]=]

function Sharp.start()
	if Sharp[started] then
		return warn(ALREADY_STARTED_ERROR)
	end

	_G.Sharp = Sharp
	Sharp[started] = true

	preparePackage()
	prepareLibrary()
	prepareSingleton()
	startSingletonLifeCycle()

	Sharp[ready] = true

	releaseAwaiting()
end

--[=[
    Accepts a callback which will be called when the Sharp framework is started.

    @param fn ()->()
    @return Sharp
]=]

function Sharp.onStart(fn)
	if Sharp[ready] then
		fn()
	else
		table.insert(Sharp[awaiting], fn)
	end

	return Sharp
end

--[=[
    Yields the current thread until the Sharp framework is started.

    @yields
    @return Sharp
]=]

function Sharp.await()
	if Sharp[ready] then
		return Sharp
	end

	local thread = coroutine.running()
	table.insert(Sharp[awaiting], thread)
	coroutine.yield(thread)

	return Sharp
end

return Sharp
