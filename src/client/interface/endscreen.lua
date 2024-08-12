local endscreen = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GameService = Knit.GetService("GameService")
local ui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main").stages.endscreen

function endscreen:Start()
    print("endscreen started")
    local leaderboard = ui.leaderboard
    local children = leaderboard:GetChildren()
    for i = 1, #children do
        if children[i]:IsA("TextLabel") then
            children[i]:Destroy()
        end
    end

    local scores = GameService:GetVotesPerPlayer():expect()
    local sortedScores = {}
    for userid, score in pairs(scores) do
        table.insert(sortedScores, {userid = userid, score = score})
    end

    table.sort(sortedScores, function(a, b)
        return a.score > b.score
    end)

    for i = 1, #sortedScores do
        local textLabel = ui.template:Clone()
        textLabel.Parent = leaderboard
        local username, err = pcall(function()
            return game.Players:GetNameFromUserIdAsync(sortedScores[i].userid)
        end)
        if username and not err then
            textLabel.Text = username .. " - " .. sortedScores[i].score
        else
            textLabel.Text = "softmodded".. sortedScores[i].userid .. " - " .. sortedScores[i].score
        end
    end
end

function endscreen:Destroy()
end

return endscreen