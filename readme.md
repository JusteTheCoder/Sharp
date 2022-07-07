<div align="center">
	<h1>Sharp</h1>
	<p>A powerful framework for networking and organization.</p>
</div>

<div align="center">
  ⚠ <b>WARNING</b>: Not quite ready for production yet. There might be bugs and missing features! ⚠
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
with the existing definition allowing cross-referencing singletons:

```lua
	-- Singleton 1
	local MySingleton1 = Sharp.Singleton.MySingleton1
	
	local MySingleton2 = Sharp.Singleton.define("MySingleton2")
	
	-- Singleton 2
	local MySingleton2 = Sharp.Singleton.MySingleton2
	
	local MySingleton1 = Sharp.Singleton.define("MySingleton1")
```

Singletons also contain optional lifecycle methods.
These methods are available to all modules inside a singleton folder not just ones
which utilize the Singleton library.

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
    local MyPackage = Sharp.Package.MyPackage
    local MySubModule = MyPackage.SubModule
```

## Networking

Sharp also offers some powerful networking features through its
built-in Net library.

### Networking basics

Net has two types of events:
    Event - Your standard event; can be fired and listened to.
    AsyncEvent - An event that only be fired on the client and returns values asynchronously through a promise.

Server-side example:
```lua
    local Net = Sharp.Library.Net
    
    local MyBridge = Net.now("MyBridge", {
        myEvent = Net.Type.Event(),
        myAsyncEvent = Net.Type.AsyncEvent()
    })

    MyBridge.myEvent:Connect(function(client, message)
        print("Client " .. client.Name .. " fired myEvent with message " .. message)
        --> "Client client fired myEvent with message Hello World!"
    end)

    MyBridge.myAsyncEvent:setCallback(function(client, ...)
        task.wait(5)
        return "Hello " .. client.Name .. "from server!"
    end)

    MyBridge.myEvent:sendToClient(Players.SomePlayer1, "Hello World!")
    MyBridge.myEvent:sendToClients({Players.SomePlayer1, Players.SomePlayer2}, "Hello World!")
    MyBridge.myEvent:sendToClientsExcept({Players.SomePlayer1, Players.SomePlayer2}, "Hello World!")
    MyBridge.myEvent:sendToAllClients("Hello World!")
```

Client-side example:
```lua
    local Net = Sharp.Library.Net

     -- On the client you can use Net.Trove to automatically get all events from the server.
    local MyBridge = Net.now("MyBridge", Net.Trove)

    MyBridge.myEvent:Connect(function(message)
        print(message) --> "Hello World!"
    end)

    MyBridge.myAsyncEvent:setTimeot(3) --> If the callback takes longer than 3 seconds, it will be aborted.

    MyBridge.myEvent:sendToServer("Hello World!")
    local status, message = MyBridge.myAsyncEvent:callServer():await()
    --> promise failed since call took longer than 3 seconds
```

### Using middleware

Sharp also offers a middleware system for networking.
There are two types of middleware:
    Inbound - Called when an event is received
    Outbound - Called when an event is sent

Server-side example:
```lua
    local MyBridge = ...

    MyBridge.myEvent:useInboundMiddleware(
        -- Limit the number of call to 10 per minute.
        Net.Middleware.throttle(10)
        -- Check if the first argument is a string.
        -- Usage with t highly recommended.
        Net.Middleware.typeCheck(function(argument)
            return type(argument) == "string"
        end)
    )

    MyBridge.myEvent:useOutboundMiddleware(
        -- Only calls the event on clients with names
        -- that are longer than 5 characters.
        Net.Middleware.block(function(client, ...)
            return client.Name:len() > 5
        end)
    )
```

Middleware only allows for cancelling an event call.
To modify the arguments use :outboundProcess() and :inboundProcess() which both
accept a function that takes the arguments and returns the modified arguments.
These are called after the middleware has been processed.

Client and server:
```lua
    local MyBridge = ...

    local function serialize(...)
        local args = table.pack(...)
        -- serialize
        return table.unpack(args, 1, args.n)
    end

    local function deserialize(...)
        local args = table.pack(...)
        -- deserialize
        return table.unpack(args, 1, args.n)
    end

    MyBridge.myEvent:inboundProcess(deserialize)
    MyBridge.myEvent:outboundProcess(serialize)
```

Are you noticing what I'm noticing?
What if we want to do more than just serialize and deserialize?
I want to have multiple functions that do different things.
In this case you can use Net.chain(...) to do just that.

```lua
    local MyBridge = ...

    local function deserialize(...)
        local args = table.pack(...)
        -- deserialize
        return table.unpack(args, 1, args.n)
    end

    local function clampNumber(number)
        return math.clamp(number, 0, 100)
    end

    MyBridge.myEvent:inboundProcess(Net.chain(deserialize, clampNumber))
```

### With singletons

On top of the Net.one constructor, Net offers two other constructors:
    Net.use - Accepts an optional table as the second argument.
    Net.with - Same as Net.use, but constructs a singleton.

```lua
    local MyNetObject = Net.use("MyNetObject", {
        value = "Hello!"
    })

    -- Again, Net.Trove can be used on the client.
    MyNetObject:netAdd({
        myEvent = Net.Type.Event(),
        myAsyncEvent = Net.Type.AsyncEvent()
    })

    -- Events are added to the table.
    MyNetObject.myEvent:Connect(function(message)
        print(message)
    end)
```

With Singletons:
```lua
    -- This doesn't look very nice.
    local MyNetObject = Net.use("MyNetObject", Sharp.Singleton.define("MyNetObject", {
        value = "Hello!"
    }))
    
    -- Instead use Net.with to which creates a singleton.
    local MyNetObject = Net.with("MyNetObject", {
        value = "Hello!"
    })

    -- Again, Net.Trove can be used on the client.
    MyNetObject:netAdd({
        myEvent = Net.Type.Event(),
        myAsyncEvent = Net.Type.AsyncEvent()
    })

    -- Events are added to the table.
    MyNetObject.myEvent:Connect(function(message)
        print(message)
    end)
```
