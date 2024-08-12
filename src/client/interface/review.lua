local review = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GameService = Knit.GetService("GameService")

local ui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main").stages.review

function review:Start()
    local children = ui.answers:GetChildren()
    for i = 1, #children do
        if children[i]:IsA("Frame") then
            children[i]:Destroy()
        end
    end

    local question = GameService:GetCurrentReviewingQuestion():expect()
    local answers = GameService:GetCurrentAnswers():expect()
    local votes = GameService:GetCurrentVotes():expect()

    ui.question.Text = question

    for userid, answer in pairs(answers) do
        local frame = ui.template:Clone()
        frame.Parent = ui.answers
        frame.Name = "vote"
        frame.Visible = true
        frame.answer.Text = answer
        frame.votes.Text = votes[userid] or 0
        if tonumber(userid) > 0 then
            frame.submitted.Text = game.Players:GetNameFromUserIdAsync(userid) .. " submitted this answer"
        else
            frame.submitted.Text = "softmodded".. userid .." submitted this answer"
            --frame.submitted.Text = "this player left (".. userid ..")"
        end
    end
end

function review:Destroy()
end

return review