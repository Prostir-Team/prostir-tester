util.AddNetworkString("PRSBOX.Net.StartTester")

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
	
	local f = file.Open("cfg//tester.json", "r", "GAME")
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

hook.Add("Initialize", "PRSBOX.Tester.CreateFile", function ()
	if file.Exists("complete_test.dat", "DATA") then return end

	file.Write("complete_test.dat", "")
end)

hook.Add("PlayerInitialSpawn", "PRSBOX.Tester.CheckUser", function (ply)
	
end)

hook.Add("PlayerDeathThink", "PRSBOX.Tester.SpawnCencel", function (ply)
	
end)

concommand.Add("test_check", function ()
	print(checkPlayer("STEAM_0:0:35902724"))
end)

concommand.Add("start_tester", function (ply)
	if not IsValid(ply) then return end
	if checkPlayer(ply:SteamID()) then return end

	ply:SetNWBool("PRSBOX.Net.Tester", true)
	
	local data = getTest()

	data = convertForClient(data)

	net.Start("PRSBOX.Net.StartTester")
		net.WriteTable(data)
	net.Send(ply)
end)

net.Receive("PRSBOX.Net.CheckTester", function (len, ply)
	
end)