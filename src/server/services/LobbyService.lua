local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Players = game:GetService("Players")

local LobbyService = Knit.CreateService {
    Name = "LobbyService",
    Client = {
        playersChange = Knit.CreateSignal();
        Countdown = Knit.CreateSignal();
        countdownCancelled = Knit.CreateSignal();
        startGame = Knit.CreateSignal();
    },
}


function LobbyService:KnitStart()
    
end

function LobbyService.Client:GetPlayers()
    return #game.Players:GetPlayers()
end

function LobbyService:KnitInit()
    self.RoundService = Knit.GetService("RoundService")
    self.GameService = Knit.GetService("GameService")
    self:InitializeEvents()
end

function LobbyService:StartCountdown()
    self.countdown = task.spawn(function()
        for i = 10, 1, -1 do
            for _, player in ipairs(game.Players:GetPlayers()) do
                self.Client.Countdown:Fire(player, i)
            end
            task.wait(1)
        end
        self.RoundService:ChangeStage("ingame")
        self.GameService:StartGame()
        for _, player in ipairs(game.Players:GetPlayers()) do
            self.Client.startGame:Fire(player)
        end
    end)
end

function LobbyService:InitializeEvents()
    game.Players.PlayerAdded:Connect(function()
        for _, player in ipairs(game.Players:GetPlayers()) do
            self.Client.playersChange:Fire(player, #game.Players:GetPlayers())
        end

        if #game.Players:GetPlayers() >= 4 then
            self:StartCountdown()
        end
    end)
    game.Players.PlayerRemoving:Connect(function()
        for _, player in ipairs(game.Players:GetPlayers()) do
            self.Client.playersChange:Fire(player, #game.Players:GetPlayers())
        end

        if #game.Players:GetPlayers() < 4 then
            print(self.countdown)
            if self.countdown then
                task.cancel(self.countdown)
                for _, player in ipairs(game.Players:GetPlayers()) do
                    self.Client.countdownCancelled:Fire(player)
                end
                self.countdown = nil
            end
        end
    end)
end

return LobbyService
