<div align="center">
	<h1>Sharp</h1>
	<a href="https://github.com/JusteTheCoder/Sharp/actions">
		<img src="https://github.com/JusteTheCoder/Sharp/actions/workflows/check.yaml/badge.svg?branch=main"/>
	</a>
</div>

## Why Sharp?

### Motivation

I've experimented with a wide variety of frameworks in the past. I've used Knit for quite a long time, but its service-controller design feels too restrictive to me. I thus made the decision to design my own.

### Structure

Sharp, in contrast to Knit, isolates the networking logic away from services and controllers, leaving behind a singleton. Singletons are also able to reference one another cross-referentially because of their internal structure.

### Networking

The net library from Sharp is a potent tool for networking. With its rich middleware api, Net is a secure and easy to use networking solution.
As much as I don't want to seem excessively ambitious, I'm fairly confident that net provides the most networking functionality of all the open source networking libraries for Roblox.

## Installation

Sharp can be installed through wally by adding it as
a dependency (e.g. `Sharp = "justethecoder/sharp@0.2.0"`)

[Installing Wally](https://github.com/UpliftGames/wally)

## Quick Start

Generally speaking, you should only use two scripts: a local script in the "StarterPlayerScripts" folder and a server script in the "ServerScriptService" folder.

The contents of those scripts in the most basic case is as follows:
```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Sharp = require(ReplicatedStorage.Packages.Sharp)

    Sharp.start() -- Yields if necessary
```

You can also utilize the two other start functions:
```lua
    Sharp.await() -- Yields until sharp is ready
    Sharp.onStart(function() -- This will be called when sharp is ready
    end)
```

After initialization, Sharp will be available as a global variable "_G.Sharp".

### Adding singletons and libraries

Locations can be added to Sharp before using the start function.
Each module under the specified location will be added to Sharp as a singleton or library, and each module's sub-modules will be added as packages.

```lua
    Sharp.addSingletons(singletonFolder)
    Sharp.addLibrary(libraryFolder)
```

### Libraries

Libraries are simply modules that are lazy loaded when required:
```lua
    local Sharp = _G.Sharp
    local MyModule = Sharp.Library.MyModule
```

### Packages

The sub-modules of both singletons and libraries can be accessed as packages, also lazy loaded:
```lua
    local Sharp = _G.Sharp
    local MySubModule = Sharp.Package.MyModule.MySubModule
```

### Singletons

Singletons are modules which are loaded when the start function is called.
To create a singleton, call the define function:
```lua
    -- The second argument is optional
    local MySingleton = Sharp.Singleton.define("MySingleton", {
        value = 10
    })

    function MySingleton.first()
    end

    -- Will be called after the first function of all singletons is called
    function MySingleton.on()
    end

    return MySingelton
```

Singletons can be accessed before they are created, and the optional data will be merged with the existing definition allowing cross-referencing singletons.
```lua
    local MySingleton = Sharp.Singleton.MySingleton
```

A singleton module is not required to return a singleton value:
```lua
    local MySingleton = {}

    -- Life cycle functions will still work.

    return MySingelton
```

### Networking

Sharp offers some powerful networking features through its built-in Net library.

#### Networking basics

Net has two types of events: 
Event - A typical event that may be called and listened to. 
AsyncEvent - An event that can be called solely on the client and returns values asynchronously via a promise.

Server-side example:
 ```lua
     local Net = Sharp.Library.Net

    local MyBridge = Net.now("MyBridge", {
        myEvent = Net.Type.event(),
        myAsyncEvent = Net.Type.asyncEvent()
    })

    MyBridge.myEvent:Connect(function(client, ...)
        print("Client " .. client.Name .. " fired MyEvent")
    end)

    MyBridge.myAsyncEvent:setCallback(function(client, ...)
        -- This can yield
        task.wait(10)
        return "Hello ".. client.Name .. "!"
    end)
    
    MyBridge.myEvent:sendToClient(client, ...)
    MyBridge.myEvent:sendToClients({client}, ...)
    MyBridge.myEvent:sendToClientsExcept({client}, ...)
    MyBridge.myEvent:sendToAllClients(...)
 ```

Client-side example:
```lua
    local Net = Sharp.Library.Net

     -- On the client you can use Net.Trove to automatically get all events from the server.
    local MyBridge = Net.now("MyBridge", Net.Trove)

    MyBridge.myEvent:Connect(function(message)
        print(message)
    end)

    MyBridge.myAsyncEvent:setTimeot(3) --> If the callback takes longer than 3 seconds, the promise will fail.

    MyBridge.myEvent:sendToServer("Hello Server!")
    local status, message = MyBridge.myAsyncEvent:callServer():await()
    --> promise failed since call took longer than 3 seconds
```

#### With singletons

On top of the Net.one constructor, Net offers two other constructors: Net.use - Accepts an optional table as the second argument. Net.with - Same as Net.use, but constructs a singleton.

```lua
    local MyNetObject = Net.use("MyNetObject", {
        value = "Hello!"
    })

    -- Again, Net.Trove can be used on the client.
    MyNetObject:netAdd({
        myEvent = Net.Type.event(),
        myAsyncEvent = Net.Type.asyncEvent()
    })

    -- Events are added to the table.
    MyNetObject.myEvent:Connect(function(message)
        print(message)
    end)
```

You can use a singleton as the second argument:
```lua
    local MyNetObject = Net.use("MyNetObject", Sharp.Singleton.define("MyNetObject", {
        value = "Hello!"
    }))
```

However that doesn't look very nice.
Use Net.with instead:
```lua
    -- Defines a singleton
    local MyNetObject = Net.with("MyNetObject", {
        value = "Hello!"
    })
```

#### Using middleware

There are two types of middleware:
Inbound - Called when an event is received
Outbound - Called when an event is sent

Server-side example:

```lua
    local MyBridge = ...

    MyBridge.myEvent:useInboundMiddleware({
        -- Limit the number of calls to 10 per minute.
        Net.Middleware.throttle(10),
        -- Check if the first argument is a string.
        -- Usage with the 't' library highly recommended.
        Net.Middleware.typeCheck(function(argument)
            return type(argument) == "string"
        end)
    })

    MyBridge.myEvent:useOutboundMiddleware({
        -- Only sends the event to client
        -- if the client's name is longer than 5 characters.
        Net.Middleware.block(function(client, ...)
            return client.Name:len() > 5
        end)
    })
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

To use more than one function, just pass them to the inboundProcess and outboundProcess methods, or create a chain of functions using Net.chain(...).

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

    -- These are the same; internally Net calls the chain function
    -- if more than one function is passed as an argument.
    MyBridge.myEvent:inboundProcess(deserialize, clampNumber)
    MyBridge.myEvent:inboundProcess(Net.chain(
    	deserialize, clampNumber
    ))
```

#### Custom middleware

Using the the following structure you can create a custom middleware.
Logger example:
```lua
	local MESSAGE = "Client '%s' fired event '%s' with arguments: %s"

	local function logger(netType)
		return function(client, ...)
			print(string.format(MESSAGE, client.Name, netType.name, table.concat({...}, ", ")))
			return true -- Return false to cancel the event.
		end
	end
```
