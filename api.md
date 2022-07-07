```lua

local SomeSingleton = Sharp.Singleton.SomeSingleton

local Library = Sharp.Library.MyLibrary
local Net = Sharp.Library.Net

local SingletonPackage = Sharp.package.Value
local SingletonClass = SingletonPackage.Class
local SingletonClass2 = SingletonPackage.Class2

local Singleton = Sharp.Singleton.define("Value")

-- On the client this works events are pulled from the server
-- Meaning they better exist at the time of calling
Net.use("Value", Singleton):share(Net.Trove)

-- Singletons can also be constructed directly with net

local Singleton = Net.with("Value")
:share(Net.Trove)

Singleton.someValue = "Hello"

-- Net can also be used outside of Singletons
Net.now("Value", Net.Trove)

function Singleton.first()
end

function Singleton.on()
end

return Singleton
```