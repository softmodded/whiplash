local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Players = game:GetService("Players")

local RoundService = Knit.CreateService {
    Name = "RoundService",
    Client = {
        stageChange = Knit.CreateSignal();
    },
    currentStage = "lobby",
}


function RoundService:KnitStart()
    
end


function RoundService:KnitInit()
    self:StartRoundCycle()
end

function RoundService:StartRoundCycle()
    -- any server logic to start the round cycle
end

function RoundService:ChangeStage(stage)
    self.currentStage = stage

    local players = Players:GetPlayers()
    for _, player in ipairs(players) do
        self.Client.stageChange:Fire(player, stage)
    end
end

function RoundService.Client:GetStage()
    return self.Server.currentStage
end


return RoundService
