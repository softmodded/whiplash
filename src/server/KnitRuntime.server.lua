local replicated = game:GetService("ReplicatedStorage")
local Knit = require(replicated.Packages.Knit)
Knit.Server = script.Parent
Knit.Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
Knit.Service = Knit.Server:WaitForChild("services")

Knit.AddServices(Knit.Service)

print("knit runtime loaded (server)")

Knit.Start()