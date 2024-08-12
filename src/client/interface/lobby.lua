local lobby = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LobbyService = Knit.GetService("LobbyService")
local ui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main").stages.lobby

function lobby:Start()
    print("Lobby started")

    local players = LobbyService:GetPlayers():expect()
    if players >= 4 then
        ui.players.Text = "players: " .. players .. " (ready)"
    else
        ui.players.Text = "players: " .. players .. "/4 (waiting)"
    end

    LobbyService.playersChange:Connect(function(players)
        if players >= 4 then
            ui.players.Text = "players: " .. players .. " (ready)"
        else
            ui.players.Text = "players: " .. players .. "/4 (waiting)"
        end
    end)

    LobbyService.Countdown:Connect(function(time)
        ui.waiting.Text = "starting in " .. time
    end)

    LobbyService.countdownCancelled:Connect(function()
        ui.waiting.Text = "waiting for players"
    end)
end

function lobby:Destroy()
end

return lobby