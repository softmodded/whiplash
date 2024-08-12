local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local TextService = game:GetService("TextService")

local questions = require(ReplicatedStorage.Shared.modules.questions)

local GameService = Knit.CreateService {
    Name = "GameService",
    Client = {
        allPlayersAnswered = Knit.CreateSignal();
    },
    startedWith = 0,
    currentPlayers = 0,
    leftPlayers = {},
    previousQuestion = nil,
    question = nil,
    answers = {},
    i = 0,
    answered = 0,
    votingOn = 0,
    questions = {},
    votes = {},
    voted = 0,
    reviewing = 0,
    votesPerPlayer = {}
}


function GameService:KnitStart()
    
end


function GameService:KnitInit()
    self.RoundService = Knit.GetService("RoundService")
    self.LobbyService = Knit.GetService("LobbyService")
end

function GameService:InitializeEvents()
    self.leaver = game.Players.PlayerRemoving:Connect(function(plr)
        if #game.Players:GetPlayers() < 4 then
            return self:EndGame()
        end

        self.currentPlayers = #game.Players:GetPlayers()
        table.insert(self.leftPlayers, plr.UserId)
    end)

    self.joiner = game.Players.PlayerAdded:Connect(function(plr)
        self.currentPlayers = #game.Players:GetPlayers()
    end)
end

function GameService:StartGame()
    self.startedWith = #game.Players:GetPlayers()
    self.currentPlayers = #game.Players:GetPlayers()
    print("Game started with " .. self.startedWith .. " players")
    self:InitializeEvents()
    task.wait(5)
    self:DoQuestion()
end

function GameService:VotingStage()
    self.voted = 0
    if self.votingOn == self.i then
        return self:ReviewStage()
    end
    self.votingOn = self.votingOn + 1
    self.votes[self.votingOn] = {}
    self.RoundService:ChangeStage("voting")
end

function GameService.Client:SubmitVote(player, userid)
    if not self.Server.votes[self.Server.votingOn][player.UserId] then
        self.Server.votes[self.Server.votingOn][player.UserId] = userid
        self.Server.voted = self.Server.voted + 1
        print(player.Name .. " voted for " .. userid)
        print(self.Server.voted, self.Server.currentPlayers)
        if self.Server.voted == self.Server.currentPlayers then
            self.Server:VotingStage()
        end
        return true
    else
        return false, "you already voted"
    end
end

function GameService:ReviewStage()
    for i = 1, self.i do
        self.reviewing = i
        self.RoundService:ChangeStage("review")
        task.wait(10)
    end
    self.RoundService:ChangeStage("endscreen")
    task.wait(10)
    self:EndGame()
end

function GameService:CalculateVotesPerPlayer()
    for i = 1, self.i do
        local votes = self.votes[i]
        for userid, vote in pairs(votes) do
            if not self.votesPerPlayer[userid] then
                self.votesPerPlayer[userid] = 1
            else
                self.votesPerPlayer[userid] = self.votesPerPlayer[userid] + 1
            end
        end
    end
end

function GameService.Client:GetVotesPerPlayer()
    self.Server:CalculateVotesPerPlayer()
    return self.Server.votesPerPlayer
end

function GameService.Client:GetCurrentAnswers()
    return self.Server.answers[self.Server.reviewing]
end

function GameService.Client:GetCurrentReviewingQuestion()
    return self.Server.questions[self.Server.reviewing]
end

function GameService.Client:GetCurrentVotes()
    return self.Server:CalculateVotes(self.Server.reviewing)
end

function GameService:CalculateVotes(vote)
    local voteCountPerAnswer = {}
    local proper = self.votes[vote]
    for _, userid in pairs(proper) do
        if not voteCountPerAnswer[userid] then
            voteCountPerAnswer[userid] = 1
        else
            voteCountPerAnswer[userid] = voteCountPerAnswer[userid] + 1
        end
    end

    print(voteCountPerAnswer)

    return voteCountPerAnswer
end

function GameService.Client:GetCurrentlyVoting()
    return self.Server.answers[self.Server.votingOn]
end

function GameService.Client:GetCurrentQuestion()
    return self.Server.questions[self.Server.votingOn]
end

function GameService:DoQuestion()
    if self.i == 2 then
        self:VotingStage()
        return 
    end

    self.i = self.i + 1
    self.answered = 0
    local question = questions[math.random(1, #questions)]
    while question == self.previousQuestion do
        question = questions[math.random(1, #questions)]
    end

    self.previousQuestion = question
    self.question = question
    self.answers[self.i] = {}
    table.insert(self.questions, question)
    self.RoundService:ChangeStage("question")
end

function GameService.Client:SubmitAnswer(player, answer)
    local filteredAnswer = ""
    local success, errorMessage = pcall(function()
        filteredAnswer = TextService:FilterStringAsync(answer, player.UserId)
    end)
    if not success then
        warn("couldnt filter answer: " .. errorMessage)
        return false, "couldn't filter answer, try again"    
    end

    if not filteredAnswer == answer then
        return false, "answer was filtered, try again"
    end

    print(self.Server.i)

    if not self.Server.answers[self.Server.i][player.UserId] then
        self.Server.answers[self.Server.i][player.UserId]  = answer
        self.Server.answered = self.Server.answered + 1
        print(player.Name .. " answered with " .. answer)
        if self.Server.answered == self.Server.currentPlayers then
            self.Server:DoQuestion()
        end
        return true
    else
        return false, "you already answered"
    end
end

function GameService.Client:GetQuestion()
    return self.Server.question
end

function GameService:EndGame()
    self.leaver:Disconnect()
    self.joiner:Disconnect()
    self.startedWith = 0
    self.currentPlayers = 0
    self.voted = 0
    self.leftPlayers = {}
    self.RoundService:ChangeStage("lobby")
    self.LobbyService:StartCountdown()
end


return GameService
