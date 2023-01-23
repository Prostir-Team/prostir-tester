util.AddNetworkString("PRSBOX.Net.StartTester")
util.AddNetworkString("PRSBOX.Net.ConfirmTester")
util.AddNetworkString("PRSBOX.Net.CheckTester")
util.AddNetworkString("PRSBOX.Net.EndTester")
util.AddNetworkString("PRSBOX.Net.GetLang")

local defaultFilename = "cfg/en_tester.json"

local function checkPlayer(steamid)
	local f = file.Open("complete_test.dat", "r", "DATA")
	if not f then return end

	local data = f:Read()
	if not isstring(data) then return false end
	data = string.Split(data, "\n")

	return table.HasValue(data, steamid)
end

local function getTest(lang)
	if not file.Exists(defaultFilename, "GAME") then return end
	
	local filename = "cfg/" .. lang .. "_tester.json"
	
	if not file.Exists(filename, "GAME") then 
		filename =  defaultFilename
	end

	local f = file.Open(filename, "r", "GAME")
	if not f then return end

	local data = f:Read()

	return util.JSONToTable(data)
end

local function convertForClient(data)
	if not istable(data) then return end
	
	local dataToClient = data

	for _, question in ipairs(table.GetKeys(dataToClient["questions"])) do
		for k, answer in ipairs(table.GetKeys(dataToClient["questions"][question])) do
			dataToClient["questions"][question][answer] = false
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
	ply:KillSilent()

	net.Start("PRSBOX.Net.GetLang")
	net.Send(ply)
end)

hook.Add("PlayerDeathThink", "PRSBOX.Tester.SpawnCencel", function (ply)
	if ply:GetNWBool("PRSBOX.Net.Tester") then
		return true 
	end
end)

concommand.Add("test_check", function ()
	print(checkPlayer("STEAM_0:0:35902724"))
end)

net.Receive("PRSBOX.Net.ConfirmTester", function (len, ply)
	if not IsValid(ply) then return end
	
	timer.Simple(101, function ()
		if not ply:GetNWBool("PRSBOX.Net.Tester") then return end
		
		ply:Kick("Ви не встигли пройти тестування")
	end)
end)

net.Receive("PRSBOX.Net.CheckTester", function (len, ply)
	local data = net.ReadTable()

	local originalData = getTest(data["lang"]["lang"])
	local questions = table.GetKeys(data["questions"])

	local rightAnswers = 0

	for _, question in ipairs(questions) do
		local answers = table.GetKeys(data["questions"][question])

		for _, answer in ipairs(answers) do
			if data["questions"][question][answer] == originalData["questions"][question][answer] and originalData["questions"][question][answer] then
				rightAnswers = rightAnswers + 1
			end
		end
	end

	if rightAnswers >= #questions then
		addPlayerToFile(ply)
		
		net.Start("PRSBOX.Net.EndTester")
		net.Send(ply)

		timer.Simple(6, function ()
			ply:SetNWBool("PRSBOX.Net.Tester", false)
			ply:Spawn()
		end)
	else
		ply:Kick("Ви не пройшли тестування")
	end
end)

concommand.Add("prsotir_tester_lang", function (ply, cmd, args)
	if not IsValid(ply) then return end
	if not ply:GetNWBool("PRSBOX.Net.Tester") then return end
	
	local lang = args[1]

	local data = getTest(lang)
	data = convertForClient(data)

	net.Start("PRSBOX.Net.StartTester")
		net.WriteTable(data)
	net.Send(ply)
end)