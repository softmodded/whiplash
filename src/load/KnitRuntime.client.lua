print("knit runtime loaded (client)")


local replicated = game:GetService("ReplicatedStorage")
local Knit = require(replicated:WaitForChild("Packages").Knit)
Knit.Client = replicated:WaitForChild("Client")
Knit.Shared = replicated:WaitForChild("Shared")
Knit.Controllers = Knit.Client:WaitForChild("controllers")
Knit.Interface = replicated:WaitForChild("Interface")

for _,file in Knit.Controllers:GetChildren() do
    require(file)
end

Knit.AddControllers(Knit.Controllers)


Knit.Start()