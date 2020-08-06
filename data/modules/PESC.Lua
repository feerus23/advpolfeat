local EXPORT = {
	_id = 'PESC', -- DONT CHANGE THIS PARAMETER!!!
	_dlu = 'https://raw.githubusercontent.com/fuexie/advpolfeat/master/data/modules/PESC.Lua', -- AND THIS PARAMETER DONT CHANGE!!!
	_author = 'Fuexie',
	_ver = '2.0'
}
local init_result, strobe_status, han
local _cfiles = {}

local lfs = require'lfs'
local scrDir = getWorkingDirectory()..'\\AdvPolFeat\\PESC\\'

local function isDir(path)
	local tmp = lfs.currentdir()
	local is = lfs.chdir(path) and true or nil
	lfs.chdir(tmp)
	return is
end

local function empty(value)
	if value == nil or #value == 0 or value:match('^%s$') then return true else return false end
end

local function intBool(variable)
	if variable == 1 then return 0 elseif variable == 0 then return 1 end
end

--[[
-- Попытка в ООП. Если хуйня - зацензу... закомменчу епта. Да закомментил как видите
-- ООП хуевое, я даже не ебу ООП это или нет ыхыххыхы, но он как бы работает через раз
-- своей жизнью живет пацанчик
local siren = {}
do
	local e = empty
	local mt = {
		__call = function(self, car, config, t)
			self:setParams(t)
			self.car, self.config = car, config; return self
		end
	}

	siren = setmetatable({ thread={ } }, mt)

	function siren:toggle()
		if self.status then
			self.thread[1]:terminate(); self.thread[2]:terminate()
			self.status = false
		else
			self.status = true
			if self.thread[1] or self.thread[2] then
				self.thread[1]:run(); self.thread[2]:run()
			else
				self.thread[1], self.thread[2] = lua_thread.create(siren.process, self, 'right', self.car), lua_thread.create(siren.process, self, 'left', self.car)
			end
		end
	end

	function siren:process(face, car)
		local ptr = getCarPointer(car) + 1440
		forceCarLights(car, 2)

		if face == 'right' or 0 then
			local status = self.right_state

			while true do
				for i = 1, self.crsw do
					callMethod(7086336, ptr, 2, 0, 0, status)
					status = intBoolSwitch(status)
					wait(self.right_switches[i])
				end
			end
		elseif face == 'left' or 1 then
			local status = self.left_state

			while true do
				for i = 1, self.clsw do
					callMethod(7086336, ptr, 2, 0, 1, status)
					status = intBoolSwitch(status)
					wait(self.left_switches[i])
				end
			end
		end
	end

	function siren:setParams(t)
		if type(t) == 'table' then
			self.right_state, self.left_state, self.crsw, self.clsw = t.right_state, t.left_state, t.corsw, t.colsw
			self.right_switches, self.left_switches = t.switches.right, t.switches.left
		end
	end

	function siren:editParams(t, cfg)
		if self.status then
			siren:toggle()
			siren:setParams(t)
			if cfg then self.config = cfg end
			siren:toggle()
		else
			if cfg then self.config = cfg end
			siren:setParams(t)
		end
	end

	function siren:getParams()
		if not e(self.right_state) then
			return { self.right_state, self.left_state, self.crsw, self.clsw, self.right_switches, self.left_switches }
		end
	end
end
--  siren - класс, аргументы
-- siren(car, right_state, left_state, count_rlight_sw, count_llight_sw, rl, ll, config_number)
-- siren.config -> номер конфигурации
]]

local function characters(str)
	local i = 0
	return function()
		i = i + 1

		if i <= #str then return str:sub(i,i), i end
	end
end

local function table_instrval(t, p, v)
	if t ~= nil then
		if t[p] == nil then
			table.insert(t, p, v)
		else
			t[p] = t[p]..v
		end
	end
end

local function readConfig(path)
	local tempTable = { rl = {}, ll = {} }
	local jusTmp, kz = {}, 1

	local configFile = io.open(scrDir..path, 'r')

	for line in configFile:lines() do
		for c in characters(line) do
			if c:match('#') then
				break
			end
			if not c:match('%s') then
				if c == ',' or c == ';' then
					kz = kz + 1
				else
					table_instrval(jusTmp, kz, c)
				end
			end
		end
	end

	do
		tempTable.vehicle_id, tempTable.num_of_config = tonumber(jusTmp[1]), tonumber(jusTmp[2])
		tempTable.right_state, tempTable.left_state = tonumber(jusTmp[3]), tonumber(jusTmp[4])
		tempTable.count_rlight_sw, tempTable.count_llight_sw = tonumber(jusTmp[5]), tonumber(jusTmp[6])

		for i = 7, 6 + tempTable.count_rlight_sw do
			table.insert(tempTable.rl, tonumber(jusTmp[i]))
		end

		for i = 7 + tempTable.count_rlight_sw, 6 + tempTable.count_rlight_sw + tempTable.count_llight_sw do
			table.insert(tempTable.ll, tonumber(jusTmp[i]))
		end
	end

	if tempTable then
		return tempTable
	else
		return nil
	end
end

local strobe = {thread={}}
strobe[1] = function(self, car, cfg)
	if not cfg then self.conf = 1 else self.conf = tonumber(cfg) end
	self.car = car
	local cft = _cfiles[getCarModel(car)][self.conf]
	self.state = { [0] = cft.right_state, [1] = cft.left_state }
	self.cos = { [0] = cft.corsw, [1] = cft.colsw }
	self.si = { [0] = cft.switches.right, [1] = cft.switches.left }
end

function strobeOn()
	if #strobe.thread < 2 then
		for i = 0, 1 do
			strobe.thread[i] = lua_thread.create(strobeProcess, strobe.car, i)
		end
	else
		for i = 0, 1 do
			strobe.thread[i]:run()
		end
	end
end

function strobeOff()
	if #strobe.thread < 2 then
		return nil
	else
		for i = 0, 1 do
			strobe.thread[i]:terminate()
		end
	end
end

function strobeProcess(car, face)
	face = tonumber(face)
	local status = strobe.state[face]
	local ptr = getCarPointer(car) + 1440

	while true do
		for i = 1, strobe.cos[face] do
			--wait(0)
			callMethod(7086336, ptr, 2, 0, face, status)
			status = intBool(status)
			wait(strobe.si[face][i])
		end
	end
end

function strobeReload()
	strobeOff() strobeOn()
end

function registerCommands()
	for k, v in pairs(EXPORT._COMMANDS) do
		sampRegisterChatCommand(k, v[1])
	end
end

function EXPORT.init()
	registerCommands()

	if isDir(scrDir) then
		for file in lfs.dir(scrDir) do
			if (file ~= '.' or file ~= '..') and string.match(string.upper(file), '%.PESC$') then
				local f = readConfig(file)
				--print(file)

				if f then
					if #_cfiles == 0 or _cfiles[f.vechile_id] == nil then
						_cfiles[f.vehicle_id] = {
							[f.num_of_config] = {
								right_state = f.right_state,
								left_state = f.left_state,
								corsw = f.count_rlight_sw,
								colsw = f.count_llight_sw,
								switches = {
									right = f.rl,
									left = f.ll
								}
							}
						}
					elseif _cfiles[f.vehicle_id] then
						_cfiles[f.vehicle_id][f.num_of_config] = {
							right_state = f.right_state,
							left_state = f.left_state,
							corsw = f.count_rlight_sw,
							colsw = f.count_llight_sw,
							switches = {
								right = rl,
								left = ll
							}
						}
					end
				end

				--f = nil
			end
		end
	else
		lfs.mkdir(scrDir)
	end
	init_result = true
end

function EXPORT.main()
	if init_result then
		return function()
		end
	else
		EXPORT.init()
		return EXPORT.main()
	end
end

local prfx = "apf/pesc"
EXPORT._COMMANDS = {
	[prfx] = {
		[1] = function ()
			slm('* Full list of commands: ', 0xD4D4D4)
			for k, v in pairs(EXPORT._COMMANDS) do
				slm(v[2], 0xD4D4D4)
			end
		end,
		[2] = 'Use /'..prfx..': to get a full list of commands.'
	},
	[prfx..'/start'] = {
		[1] = function(conf)
			local car = storeCarCharIsInNoSave(PLAYER_PED)
			if not conf then conf = 1 end
			print(#_cfiles)
			--strobe[1](strobe, car, conf)
			--print(strobe.cos[0])
			--strobeOn()
		end,
		[2] = 'Use /'..prfx..'/start [configuration number] : to activate stroboscopes.'
	}
}

return EXPORT
