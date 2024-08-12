local ingame = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GameService = Knit.GetService("GameService")
local ui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main").stages.ingame

function ingame:Start()
    print("Ingame started")
end

function ingame:Destroy()
end

return ingame