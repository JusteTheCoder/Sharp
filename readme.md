<div align="center">
	<h1>Sharp</h1>
	<p>A powerful framework for code organization and structure.</p>
</div>

<div align="center">
  ⚠ <b>WARNING</b> :Not quite ready for production yet. There might be bugs and missing features! ⚠
</div>

## Initialization

```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Sharp = require(ReplicatedStorage:WaitForChild("Sharp"))

    Sharp.onStart(function()
        print("Sharp is ready!")
    end)

    task.spawn(function()
        Sharp.await() -- Yield until Sharp is ready.
    end)

    Sharp.start() -- Yields if necessary
```

After initialization, Sharp can be accessed through the `Sharp` global variable.

## Adding libraries and singletons

You can add folders containing modules as either libraries or singletons.
This must be done before initialization.

```lua
    Sharp.addLibraries(ReplicatedStorage.Source.Libraries)
    Sharp.addSingletons(ReplicatedStorage.Source.Singletons)
```

## Libraries

Libraries are modules which are lazy loaded when needed.
They can be accessed after initialization through the `Sharp.Library` table.

```lua
    local Signal = Sharp.Library.Signal
    local Promise = Sharp.Library.Promise
```

## Singletons

Singletons are the core of Sharp. They are a way to create a single instance of a class that can be accessed from anywhere in the code.

Accessing singletons:
```lua
    local MySingleton = Sharp.Singleton.MySingleton
```

Creating singletons:
```lua
    local MySingleton = Sharp.Singleton.define("MySingleton")
    MySingleton.someValue = "Hello!"
```
or
```lua
    local MySingleton = Sharp.Singleton.define("MySingleton", {
        someValue = "Hello!"
    })
```

Singletons can be accessed before they are created, and the optional data will be merged
with the existing definition.

Singletons also contain optional lifecycle methods.

```lua
    function MySingleton.first()
    end

    -- The on function is called only after all first methods have been called.
    function MySingleton.on()
    end
```

## Packages

Packages are a way to access sub-modules of singletons and libraries.
Also lazy loaded.

```lua
    local MyPackage = Sharp.package.MyPackage
    local MySubModule = MyPackage.SubModule
```
