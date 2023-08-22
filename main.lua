-- SCRIPT IN SERVERSCRIPTSERVICE

local funnyObjectsFolder = game.ServerStorage.FunnyObjects
local fightersFolder = workspace.Fighters

local NUM_PAPER = 50
local NUM_ROCK = 50
local NUM_SCISSORS = 50

local BOUNDARY_SIZE = 500 -- Width of the 3D Cube all the fighters will be placed in
local STEP = 1 -- Studs per loop
local STEPS_PER_SECOND = 100
local SECONDS_BEFORE_RESTART = 5

local allFighters = {
	Rock = {},
	Paper = {},
	Scissors = {}
}

-- Creates all the fighters and positions them
function setFighters()
	for i = 1, NUM_ROCK do
		local newRock = funnyObjectsFolder.Rock:Clone()
		newRock.Position = Vector3.new(math.random(0, BOUNDARY_SIZE), math.random(0, BOUNDARY_SIZE), math.random(0, BOUNDARY_SIZE))
		newRock.Parent = fightersFolder
		table.insert(allFighters.Rock, newRock)
	end
	for i = 1, NUM_PAPER do
		local newPaper = funnyObjectsFolder.Paper:Clone()
		newPaper.Position = Vector3.new(math.random(0, BOUNDARY_SIZE), math.random(0, BOUNDARY_SIZE), math.random(0, BOUNDARY_SIZE))
		newPaper.Parent = fightersFolder
		table.insert(allFighters.Paper, newPaper)
	end
	for i = 1, NUM_SCISSORS do
		local newScissors = funnyObjectsFolder.Scissors:Clone()
		newScissors.Position = Vector3.new(math.random(0, BOUNDARY_SIZE), math.random(0, BOUNDARY_SIZE), math.random(0, BOUNDARY_SIZE))
		newScissors.Parent = fightersFolder
		table.insert(allFighters.Scissors, newScissors)
	end
end

-- Main Loop
while true do
	setFighters()
	while wait(STEPS_PER_SECOND^-1) do
		-- Check if a fighter has  won
		if #(allFighters.Rock) == 0 and #(allFighters.Paper) == 0 then
			print("Scissors won!")
			break
		elseif #(allFighters.Paper) == 0 and #(allFighters.Scissors) == 0 then
			print("Rock won!")
			break
		elseif #(allFighters.Scissors) == 0 and #(allFighters.Rock) == 0 then
			print("Paper won!")
			break
		end
		
		for i, fighter in pairs(fightersFolder:GetChildren()) do
			if not fighter then continue end -- skips dead fighters, killed inside this same loop
			
			local allPrey = allFighters[fighter:GetAttribute("Prey")] -- Finds all the enemies that the fighter can kill
			
			local partsInBox = workspace:GetPartBoundsInBox(fighter.CFrame, fighter.Size, OverlapParams.new()) -- Returns all the enemies currently touching the fighter
			for a, part in partsInBox do
				for b, prey in allPrey do
					if part == prey then -- kill it and create a new one
						local deadCFrame = prey.CFrame
						if table.find(allFighters[prey.Name], prey) then
							table.remove(allFighters[prey.Name], table.find(allFighters[prey.Name], prey))
						end
						prey:Destroy()
						local newFighter = fighter:Clone()
						newFighter.CFrame = deadCFrame
						newFighter.Parent = fightersFolder
						table.insert(allFighters[fighter.Name], newFighter)
					end
				end
			end
			
			-- searches for the closest prey (if there even is one)
			local closestPrey = nil
			for a, prey in allPrey do
				if not closestPrey or (prey.Position - fighter.Position).Magnitude < (closestPrey.Position - fighter.Position).Magnitude then
					closestPrey = prey
				end
			end
			
			if closestPrey then -- go towards the prey
				local testPart = Instance.new("Part", workspace)
				testPart.Anchored = true
				testPart.CanCollide = false
				testPart.Transparency = 1
				testPart.CFrame = CFrame.new(fighter.Position, closestPrey.Position)
				local direction = testPart.CFrame.LookVector
				testPart:Destroy()
				
				fighter.Position = fighter.Position + (direction * STEP)
			end
		end
	end
	wait(SECONDS_BEFORE_RESTART)
	-- Clear the playing field
	for i, v in pairs(fightersFolder:GetChildren()) do
		v:Destroy()
	end
	allFighters = {
		Rock = {},
		Paper = {},
		Scissors = {}
	}
end
