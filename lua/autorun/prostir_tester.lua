if SERVER then
    include("prostir_tester/sv_tester.lua")

    AddCSLuaFile("prostir_tester/cl_tester.lua")
end

if CLIENT then
    include("prostir_tester/cl_tester.lua")
end