print("Tester client has started")

[[ --
    Константи
-- ]]



[[ --
    Основна панель
-- ]]

do 
    local PANEL = {}
    
    function PANEL:Init()
        self:Dock(FILL)
    end

    function PANEL:PerformLayout(w, h)
        
    end

    function PANEL:Paint(w, h)
        
    end

    vgui.Register("PRSBOX.Tester.Main", PANEL, "EditablePanel")
end

concommand.Add("tester_run", function (ply, cmd, args)
    if not IsValid(ply) then return end

    
end)