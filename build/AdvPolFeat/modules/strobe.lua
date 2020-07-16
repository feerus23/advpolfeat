-- AUTHOR: Fuexie
-- For module ExtendedStrobescopes
local strobe = {
	_id = 'STROBE', -- DONT CHANGE THIS PARAMETER!!!
	_dlu = 'apf.io/modules/strobe.lua', -- AND THIS PARAMETER DONT CHANGE!!!
	_author = 'Fuexie'
}

local scr_data = {
	setup = nil,
	main_dir = getWorkingDirectory()..'\\AdvPolFeat\\',
	cfg_dir = getWorkingDirectory()..'\\AdvPolFeat\\APF\\'
}
local list_apf = {}
local lfs = require"lfs"

function isDir(path)
	local tmp = lfs.currentdir()
	local is = lfs.chdir(path) and true or nil
	lfs.chdir(tmp)
	return is
end

function siter (s, i)
	if i < #s then i = i + 1 return i, s:sub(i, i) end
end

function chars(s)
	return siter, s, 0
end

function tbl_add(tbl, pos, val)
	if tbl ~= nil then
		if tbl[pos] == nil then
			table.insert(tbl, pos, val)
		else
			tbl[pos] = tbl[pos]..val
		end
	else
		return nil
	end
end

function ti2t(tbl1, tbl2, name)
	if tostring(type(tbl1)) == 'table' and tostring(type(tbl1)) == 'table' then
		if #name > 0 then
			tbl1[name] = tbl2
		else
			for i = 1, #tbl2 do
				tbl1[#tbl1 + i] = tbl2[i]
			end
		end
	else
		return nil
	end
end

if isDir(scr_data.cfg_dir) then
	for file in lfs.dir(scr_data.cfg_dir) do
		list_apf[#list_apf+1] = file
	end
	for i=1,2 do table.remove(list_apf, 1) end
else
	lfs.mkdir(scr_data.cfg_dir)
	scr_data.setup = false
end

function read_apf(path)
	local aqparat = {
		vehicle_id,
		num_of_config,
		state,
		nors,
		nols,
		rl = {},
		ll = {}
	}

	--print (unpack(list_apf)) -- debug #1

	local tmp = {}
	local kz = 1

	local cfgl = io.open(scr_data.cfg_dir .. path, "r")
	--print(list_apf[i]) -- debug #2
	for line in cfgl:lines() do
		local sym = {}
		for _, c in chars(line) do
			if not c:match('#') then
				if not c:match('%s') then
					if c ~= ',' and c ~= ';' then
						tbl_add(tmp, kz, c)
					else
						kz = kz + 1
					end
					sym[#sym+1] = c
				end
			else
				break
			end
		end
	end

	aqparat.vehicle_id = tonumber(tmp[1])
	aqparat.num_of_config = tonumber(tmp[2])
	aqparat.state = tonumber(tmp[3])
	aqparat.nors = tonumber(tmp[4])
	aqparat.nols = tonumber(tmp[5])
	for i = 6, aqparat.nors + 5 do
		table.insert(aqparat.rl, tmp[i])
	end
	for i = 6 + aqparat.nors, 6 + aqparat.nors + aqparat.nols do
		table.insert(aqparat.ll, tmp[i])
	end

	return aqparat
end

local _es_init = {}
function strobe.init()
	for i = 1, #list_apf do
		local vc = read_apf(list_apf[i])
		if #_es_init == 0 then
			ti2t(_es_init, vc, i)
		else
			for j = 1, #_es_init do
				if _es_init[j].vehicle_id == vc.vehicle_id and _es_init[j].num_of_config == vc.num_of_config then
					return print('Ошибка при инициализации. Cуществуют файлы с одинаковым значением vehicle_id и num_of_config')
				else
					ti2t(_es_init, vc, i)
				end
			end
		end
	end
end

--[[
function es_strobe(v_id, c_id)
	local ei = _es_init
	for i = 1, #ei do
		if v_id == ei[i].vehicle_id and c_id == ei[i].num_of_config then
			local _r = coroutine.create(function() for _, v in pairs(ei[i].rl) do
				sleep(1000)
				print(_..v)
				-- do something
			end end)
			local _l = coroutine.create(function() for _, v in pairs(ei[i].ll)do
				sleep(1000)
				--sleep(tonumber(v))
				print(_..v)
				-- do something
			end end)
			coroutine.resume(_r)
			coroutine.resume(_l)
		end
	end
end]]

function strobe.main()
	strobe.init()
	strobe.init_table = _es_init
	--es_strobe(400,1)
end
--print(_es_init[2].num_of_config) -- one more too debug

return strobe
