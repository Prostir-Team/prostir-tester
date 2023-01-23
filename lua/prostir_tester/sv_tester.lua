util.AddNetworkString("PRSBOX.Net.StartTester")
util.AddNetworkString("PRSBOX.Net.CheckTester")
util.AddNetworkString("PRSBOX.Net.EndTester")

local function checkPlayer(steamid)
	local f = file.Open("complete_test.dat", "r", "DATA")
	if not f then return end

	local data = f:Read()
	if not isstring(data) then return false end
	data = string.Split(data, "\n")

	return table.HasValue(data, steamid)
end

local function getTest()
	if not file.Exists("cfg/tester.json", "GAME") then return end
	
	local f = file.Open("cfg/tester.json", "r", "GAME")
	if not f then return end

	local data = f:Read()

	return util.JSONToTable(data)
end

local function convertForClient(data)
	if not istable(data) then return end
	
	local dataToClient = data

	for _, question in ipairs(table.GetKeys(dataToClient)) do
		for k, answer in ipairs(table.GetKeys(dataToClient[question])) do
			dataToClient[question][answer] = false 
		end
	end

	return dataToClient
end

local function addPlayerToFile(ply)
	if not IsValid(ply) then return end
	local steamid = ply:SteamID()

	file.Append("complete_test.dat", steamid .. "\n")
end

hook.Add("Initialize", "PRSBOX.Tester.CreateFile", function ()
	if file.Exists("complete_test.dat", "DATA") then return end

	file.Write("complete_test.dat", "")
end)

hook.Add("PlayerSpawn", "PRSBOX.Tester.CheckUser", function (ply)
	if not IsValid(ply) then return end
	if checkPlayer(ply:SteamID()) then return end

	ply:SetNWBool("PRSBOX.Net.Tester", true)
	
	local data = getTest()
	data = convertForClient(data)

	net.Start("PRSBOX.Net.StartTester")
		net.WriteTable(data)
	net.Send(ply)

	ply:KillSilent()
end)

hook.Add("PlayerDeathThink", "PRSBOX.Tester.SpawnCencel", function (ply)
	return not ply:GetNWBool("PRSBOX.Net.Tester")
end)

concommand.Add("test_check", function ()
	print(checkPlayer("STEAM_0:0:35902724"))
end)


net.Receive("PRSBOX.Net.CheckTester", function (len, ply)
	local data = net.ReadTable()

	local originalData = getTest()
	local questions = table.GetKeys(data)

	local rightAnswers = 0

	for _, question in ipairs(questions) do
		local answers = table.GetKeys(data[question])

		for _, answer in ipairs(answers) do
			if data[question][answer] == originalData[question][answer] and originalData[question][answer] then
				rightAnswers = rightAnswers + 1
			end
		end
	end

	if rightAnswers >= #questions then
		addPlayerToFile(ply)
		
		net.Start("PRSBOX.Net.EndTester")
		net.Send(ply)

		ply:SetNWBool("PRSBOX.Net.Tester", false)
		ply:Spawn()
	else
		
	end
end)