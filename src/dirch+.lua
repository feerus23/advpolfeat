-- Полностью интегрирован в основной скрипт
-- FUEXIE author

local scr_data = {
	setup = nil,
	main_dir = 'AdvPolFeat\\'
}
local lfs = require"lfs"

function isDir(path)
	local tmp = lfs.currentdir()
	local is = lfs.chdir(path) and true or nil
	lfs.chdir(tmp)
	return is
end

local list = {}
if isDir(scr_data.main_dir) then
	for file in lfs.dir(scr_data.main_dir) do
		list[#list+1] = file
	end
	for i=1,2 do table.remove(list, 1) end
else
	lfs.mkdir(scr_data.main_dir)
	scr_data.setup = false
end

print(list[1]) -- debug #2.1
