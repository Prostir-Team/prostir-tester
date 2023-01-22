print("Tester client has started")

--[[
	Шрифти
--]]

surface.CreateFont("PRSBOX.Font.Main", {
	["font"] = "Roboto",
	["extended"] = true,
	["size"] = ScreenScale(20),
	["weight"] = 700
})

surface.CreateFont("PRSBOX.Font.Second", {
	["font"] = "Roboto",
	["extended"] = true,
	["size"] = ScreenScale(12),
	["weight"] = 700
})

--[[
	Константи
--]]

local color_white = Color( 255, 255, 255 )
local color_yellow = Color( 255, 255, 0 )
local color_blue = Color( 100, 100, 200 )

local color_background_color = Color( 0, 0, 0, 200 )
local color_background_color_hovered = Color( 0, 0, 0, 230 )
local color_gray = Color(126, 126, 126)

local color_accept = Color(142, 255, 114)

--[[
	Кнопка
--]]

do
	local PANEL = {}

	function PANEL:Init()
		self.Clicked = false 

		self:SetFont("PRSBOX.Font.Second")
		self:SetColor(color_white)
	end

	function PANEL:SetClicked(clicked)
		self.Clicked = clicked
	end

	function PANEL:DoClick()
		self:SetClicked(true)
		self:OnClick()
	end

	function PANEL:OnClick()
		
	end

	function PANEL:PerformLayout(w, h)
		local tallButton = ScreenScale(20)
		local round = ScreenScale(5)

		self:SetTall(tallButton)
	end

	function PANEL:Paint(w, h)
		local round = ScreenScale(5)

		if self:IsHovered() then
			surface.SetDrawColor(color_background_color_hovered)
			surface.DrawRect(round, 0, w - round * 2, h)

			draw.RoundedBoxEx(round, w - round, 0, round, h, color_background_color_hovered, false, true, false, true)
		else
			surface.SetDrawColor(color_background_color)
			surface.DrawRect(round, 0, w - round * 2, h)

			draw.RoundedBoxEx(round, w - round, 0, round, h, color_background_color, false, true, false, true)
		end

		if self.Clicked then
			draw.RoundedBoxEx(round, 0, 0, round, h, color_accept, true, false, true, false)
		else
			if self:IsHovered() then
				draw.RoundedBoxEx(round, 0, 0, round, h, color_background_color_hovered, true, false, true, false)
			else
				draw.RoundedBoxEx(round, 0, 0, round, h, color_background_color, true, false, true, false)
			end
		end
		
	end

	vgui.Register("PRSBOX.Tester.Button", PANEL, "DButton")
end

--[[
	Початкова панель
--]]

do
	local PANEL = {}

	function PANEL:Init()
		self:Dock(FILL)

		local startButton = vgui.Create("PRSBOX.Tester.Button", self)
		if IsValid(startButton) then
			self.StartButton = startButtons
			
			startButton:Dock(BOTTOM)
			startButton:SetText("Почати тестування")

			function startButton:OnClick()
				local parent = self:GetParent()
				if not IsValid(parent) then return end

				parent:Start()
			end
		end
	end

	function PANEL:Start()
		self:AlphaTo(0, 0.5, 0, function ()
			local parent = self:GetParent()
			if not IsValid(parent) then return end

			parent:Start()
		end)
	end

	function PANEL:PerformLayout(w, h)
		local startButton = self.StartButton
		if IsValid(startButton) then

		end
	end

	function PANEL:Paint(w, h)
		draw.DrawText("Вітаємо на Простір Sandbox!", "PRSBOX.Font.Main", w/2, 0, color_white, TEXT_ALIGN_CENTER)
	end

	vgui.Register("PRSBOX.Tester.Start", PANEL, "EditablePanel")
end

--[[
	Основна панель
--]]

do 
	local PANEL = {}
	
	function PANEL:Init()
		self:Dock(FILL)
		self:MakePopup()

		local testMenu = vgui.Create("DScrollPanel", self)
		if IsValid(testMenu) then
			self.TestMenu = testMenu
			testMenu:Dock(FILL)
		end
		
		local startMenu = vgui.Create("PRSBOX.Tester.Start", self)
		if IsValid(startMenu) then
			self.StartMenu = startMenu
			startMenu:Dock(FILL)
		end

		self.PanelChildren = {}
	end

	function PANEL:Start()
		local testSize = ScreenScale(12)
		local offset = ScreenScale(5)
		
		local startMenu = self.StartMenu
		if IsValid(startMenu) then
			startMenu:Remove()
		end

		local testMenu = self.TestMenu
		if IsValid(testMenu) then
			local questions = table.GetKeys(self.TesterData)

			for _, question in ipairs(questions) do
				local questionLabel = vgui.Create("DLabel")
				if not IsValid(questionLabel) then continue end
				testMenu:AddItem(questionLabel)
				
				questionLabel:SetText(question)
				questionLabel:SetFont("PRSBOX.Font.Second")
				questionLabel:SetTextColor(color_white)
				questionLabel:SetTall(testSize)
				questionLabel:Dock(TOP)
				questionLabel:DockMargin(0, 0, 0, offset)
				
				local grid = vgui.Create("EditablePanel")
				if not IsValid(grid) then continue end
				testMenu:AddItem(grid)

				grid:SetTall(ScreenScale(20))
				grid:Dock(TOP)
				
				local answers = table.GetKeys(self.TesterData[question])
				for _, answer in ipairs(answers) do
					local button = vgui.Create("PRSBOX.Tester.Button", grid)
					if not IsValid(button) then continue end

					button:SetText(answer)
					button:SetWide((testMenu:GetWide() - offset * #answers) / #answers)
					button:DockMargin(0, 0, offset, 0)
					button:Dock(LEFT)

					button.OnClick = function ()
						local children = grid:GetChildren()
						
						for _, b in ipairs(children) do
							b:SetClicked(false)
							self.TesterData[question][b:GetText()] = false
						end

						button:SetClicked(true)

						self.TesterData[question][button:GetText()] = true 
					end
				end
			end
		end
	end

	function PANEL:Setup(data)
		self.TesterData = data
	end

	function PANEL:PerformLayout(w, h)
		local leftRightMargin = ScreenScale(200)
		local topDownMargin = ScreenScale(150)

		local leftRightTestMargin = ScreenScale(100)
		local topDownTestMargin = ScreenScale(10)
		
		local startMenu = self.StartMenu
		if IsValid(startMenu) then
			startMenu:DockMargin(leftRightMargin, topDownMargin, leftRightMargin, topDownMargin)
		end
		
		local testMenu = self.TestMenu
		if IsValid(testMenu) then
			testMenu:DockMargin(leftRightTestMargin, topDownTestMargin, leftRightTestMargin, topDownTestMargin)
		end
	end

	function PANEL:Paint(w, h)
		surface.SetDrawColor(color_background_color)
		surface.DrawRect(0, 0, w, h)
	end

	vgui.Register("PRSBOX.Tester.Main", PANEL, "EditablePanel")
end

if IsValid(TEST_PANEL) then
	TEST_PANEL:Remove()
end

net.Receive("PRSBOX.Net.StartTester", function (len, ply)
	local data = net.ReadTable()

	TEST_PANEL = vgui.Create("PRSBOX.Tester.Main")
	TEST_PANEL:Setup(data)
end)