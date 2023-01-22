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
		if not clicked then return end

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
		self:SetTextInset(round, 0)

		self:SetTall(tallButton)
	end

	function PANEL:Paint(w, h)
		local round = ScreenScale(5)

		if self:IsHovered() then
			draw.RoundedBoxEx(round, round, 0, w - round, h, color_background_color_hovered, false, true, false, true)
		else
			draw.RoundedBoxEx(round, round, 0, w - round, h, color_background_color, false, true, false, true)
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
		
		self:MakePopup()

		local startButton = vgui.Create("PRSBOX.Tester.Button", self)
		if IsValid(startButton) then
			self.StartButton = startButtons
			
			startButton:Dock(BOTTOM)
			startButton:SetText("Почати тестування")
		end
	end

	function PANEL:PerformLayout(w, h)
		local startButton = self.StartButton
		if IsValid(startButton) then

		end
	end

	function PANEL:Paint(w, h)
		-- surface.SetDrawColor(Color(255, 0, 0))
		-- surface.DrawRect(0, 0, w, h)

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

		local startMenu = vgui.Create("PRSBOX.Tester.Start", self)
		if IsValid(startMenu) then
			self.StartMenu = startMenu
			startMenu:Dock(FILL)
		end
	end

	function PANEL:PerformLayout(w, h)
		local leftRightMargin = ScreenScale(200)
		local topDownMargin = ScreenScale(150)
		
		local startMenu = self.StartMenu
		if IsValid(startMenu) then
			startMenu:DockMargin(leftRightMargin, topDownMargin, leftRightMargin, topDownMargin)
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

concommand.Add("tester_run", function (ply, cmd, args)
	if not IsValid(ply) then return end

	TEST_PANEL = vgui.Create("PRSBOX.Tester.Main")
end)