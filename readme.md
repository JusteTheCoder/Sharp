<div align="center">
	<h1>Sharp</h1>
	<a href="https://github.com/JusteTheCoder/Sharp/actions">
		<img src="https://github.com/JusteTheCoder/Sharp/actions/workflows/check.yaml/badge.svg?branch=main"/>
	</a>
</div>

## Why Sharp?

### Motivation

In the past I've tried tons of different frameworks. For the longest time I used Knit
,however to me Knits service-controller architecture feels too restrictive. So I decided to create my own.

### Structure

Unlike Knit, Sharp abstracts the networking functionality away from services and controllers leaving 
away a lifecycle object known as a singleton. Due to the internal structure of singletons they also
permit cross-referencing between each other.

### Networking

Sharp comes packed in with a powerful networking library called SharpNet, or just net. Net is a safe
solution for networking offering an extensive middleware api. 

Now I don't want to sound too ambitious, but I'm fairly confident that Net offers the most
functionality out of all open-source networking libraries designed for Roblox development.

## Installation

Sharp can be installed through wally by adding it as
a dependency (e.g. `Sharp = "justethecoder/sharp@3.0.0"`)

[Installing Wally](https://github.com/UpliftGames/wally)

## Quick Start

Now generally you'll want to use only two scripts: one localscript in 'StarterPlayerScripts' and one
serverscript in 'ServerScriptService'.

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

Before calling the start function you can add locations to Sharp.
All modules under the given location will be added to Sharp as either singletons or libraries
and their sub-modules as packages.

```lua
    Sharp.addSingletons(singletonFolder)
    Sharp.addLibrary(libraryFolder)
```

### Libraries

Libraries are simply modules which are lazy-loaded when they are accessed.
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

Accessing singletons:
```lua
    local MySingleton = Sharp.Singleton.MySingleton
```

Singleton modules aren't forced to return a singleton value:
```lua
    local MySingleton = {}

    -- Life cycle functions will still work.

    return MySingelton
```

### Networking

Sharp offers some powerful networking features through its built-in Net library.

#### Networking basics

Net has two types of events: Event - Your standard event; can be fired and listened to. AsyncEvent - An event that can only be fired on the client and returns values asynchronously through a promise.

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
So use Net.with instead:
```lua
    -- Defines a singleton
    local MyNetObject = Net.with("MyNetObject", {
        value = "Hello!"
    })
```

### Using middleware

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
        -- Usage with t highly recommended.
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

To use multiple functions use simply pass multiple functions
to the inboundProcess and outboundProcess methods or use Net.chain(...) to construct
a chain of functions.

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