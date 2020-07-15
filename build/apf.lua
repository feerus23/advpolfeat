script_name('Advanced Police Features')
script_description('Advanced features for police factions')
script_version('0.9')
script_version_number(0900)
script_author('Fuexie')
----[============================================> меч епта
local imgui = require('imgui')

local m = require('AdvPolFeat.modules')

----[============================================> меч епта
-- Вся хуйня связанная с имхуем
local ws = {
	['main'] = imgui.ImBool(false)
}

function imgui.OnDrawFrame()
	if ws['main'].v then
		imgui.ShowTestWindow(ws['main'])
	end
end

----[============================================> меч епта
-- Основной блок
local function modules_loader(tab)
  if tostring(type(tab)) ~= 'table' then
    return "Error. Argument-value isn't table"
  else
    local _, fmit = m.init()
  end
end

function main()
  registerCommands()
  while true do
    wait(0)
    imgui.Process = true
  end
end

local function registerCommands()
  local reg_cmd = sampRegisterChatCommand
  reg_cmd("apf/gui", function() ws['main'].v = not ws['main'].v)
end

main()
