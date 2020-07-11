script_name('Advanced Police Features')
script_description('Advanced features for police factions')
script_version('0.9')
script_version_number(0900)
script_author('Fuexie')
-- Requires and other
local imgui = require 'imgui'
local fxss = require 'fxss'
local lfs = require"lfs"

local scr_data = {
	setup = nil,
	first_run = true,
	main_dir = 'AdvPolFeat\\'
}

local dirlist = {}

local ws = {
	['main'] = imgui.ImBool(false)
}

function isDir(path)
	local tmp = lfs.currentdir()
	local is = lfs.chdir(path) and true or nil
	lfs.chdir(tmp)
	return is
end

function imgui.OnDrawFrame()
	if ws['main'].v then
		imgui.ShowTestWindow(ws['main'])
	end
end

function main()
	sampRegisterChatCommand('dert', cmd_dert)
	--if first_run then first_run = not first_run sampAddChatMessage('* [AdvPolFeat]: Спасибо за установку скрипта. ', -1)
	if not isDir(scr_data.main_dir) then
		lfs.mkdir(scr_data.main_dir)
		scr_data.setup = false
	else
		for file in lfs.dir(scr_data.main_dir) do
			list[#dirlist+1] = file
		end
		for i=1,2 do table.remove(dirlist, 1) end
	end
	
	while true do
		wait(0)
		imgui.Process = true
	end
end

function cmd_dert(S)
	ws['main'].v = not ws['main'].v
	fxss.style(S)
end