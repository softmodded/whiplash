local voting = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GameService = Knit.GetService("GameService")

local ui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main").stages.voting

local click

function voting:Start()
    local children = ui.answers:GetChildren()
    for i = 1, #children do
        if children[i]:IsA("Frame") then
            children[i]:Destroy()
        end
    end

    local votes = GameService:GetCurrentlyVoting():expect()
    local question = GameService:GetCurrentQuestion():expect()

    ui.question.Text = question

    for userid, answer in pairs(votes) do
        local frame = ui.template:Clone()
        frame.Parent = ui.answers
        frame.Name = "vote"
        frame.Visible = true
        frame.answer.Text = answer
        --[[
        if tonumber(userid) > 0 then
            frame.submitted.Text = game.Players:GetNameFromUserIdAsync(userid) .. " submitted this answer"
        else
            frame.submitted.Text = "softmodded".. userid .." submitted this answer"
            --frame.submitted.Text = "this player left (".. userid ..")"
        end
        ]]

        frame.submitted.Text = ""

        click = frame.click.MouseButton1Click:Connect(function()
            GameService:SubmitVote(userid)
            click:Disconnect()
            local chidren = ui.answers:GetChildren()
            for i = 1, #chidren do
                if chidren[i]:IsA("Frame") then
                    chidren[i]:Destroy()
                end
            end
            ui.question.Text = "Waiting for other players to vote..."
        end)
    end
end

function voting:Destroy()
    if click then
        click:Disconnect()
    end
end

return voting