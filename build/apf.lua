script_name('Advanced Police Features')
script_description('Advanced features for police factions')
script_version('0.9')
script_version_number(0900)
script_author('Fuexie')
----[============================================> меч епта
local imgui = require'imgui'
local lfs = require'lfs'
local encoding = require'encoding'
local inicfg = require 'inicfg'
local https = require'https'

encoding.default = 'CP1251'
local u8 = encoding.UTF8

----[============================================> меч епта
-- Переменные, функции и другое барахло
function siter (s, i)
	if i < #s then i = i + 1 return i, s:sub(i, i) end
end

function chars(s)
	return siter, s, 0
end

local reg_cmd = sampRegisterChatCommand

local data = {
	["dynamic_data"] = {
		["first_start"] = true, -- by default: true
		["init_message"] = true,
		["main_language"] = "russian",
	},
	["static_data"] = {
		["main_path"] = getWorkingDirectory()..'\\AdvPolFeat',
		["json_settings_path"] = getWorkingDirectory()..'\\AdvPolFeat\\settings.json',
		["colors"] = {
			["default"] = 0xD4D4D4
		},
		["download_url"] = {
			["load.lua"] = "https://raw.githubusercontent.com/fuexie/advpolfeat/master/build/AdvPolFeat/load.lua",
			["language.json"] = "https://raw.githubusercontent.com/fuexie/advpolfeat/master/build/AdvPolFeat/language.json"
		},
		["developer_telegram"] = "t.me/fuexie"
	}
}

local dyn_data = data["dynamic_data"]
local sdata = data["static_data"]
local mspath = sdata["main_path"]
local jspath = sdata["json_settings_path"]

local COL_DEF = sdata["colors"]["default"]

function jsonConfigSave(tab, path)
	local f, err = io.open(path, 'w')
	if not f then
		return nil, err
	end
	local tbl = require'json'.encode(tab)
	f:write(tbl)
	return true
end

function jsonConfigLoad(path, tab)
	if tab == nil then tab = dyn_data end
	local f, err = io.open(path, 'r')
	if not f then
		if not doesDirectoryExist(getWorkingDirectory()..'\\AdvPolFeat\\') then lfs.mkdir(getWorkingDirectory()..'\\AdvPolFeat\\') end
		local jfle = io.open(path, 'w')
		local tbl = require'json'.encode(tab)
		jfle:write(tbl)
		jfle:close()
		return dyn_data
	else
		local cfg = f:read('*a')
		f:close()
		return require'json'.decode(cfg)
	end
end

local ddata = jsonConfigLoad(jspath)
local lang = ddata["main_language"]

function slm(mes, col1, col2)
	local col_braces = false
	tmp = mes:gsub("({[a-zA-Z0-9]+})","")
	if #tmp > 107 then
		local large_mes, line, counter = {}, 1, 0
		for _, c in chars(mes) do
			--print(c)
			if c:match("{") then col_braces = true end
			if c:match("}") then col_braces = false end
			--if c == '\\'
			if not col_braces then
				counter = counter + 1
			end
			if counter > 80 and c == " " then
				large_mes[line] = large_mes[line]..' ...'
				line = line + 1
				large_mes[line] = '... '..c
				counter = 0
			else
				if #large_mes ~= 0 then large_mes[line] = large_mes[line]..c else large_mes[line] = c end
			end
		end
		--print(line)
		for i = 1, line do
			if col2 ~= nil then sampAddChatMessage('{'..col1..'}'..large_mes[i], col2) else sampAddChatMessage(large_mes[i], col1) end
		end
	else
		if col2 ~= nil then sampAddChatMessage('{'..col1..'}'..mes, col2) else sampAddChatMessage(mes, col1) end
	end
end

function checkPresenceThirdModules(table)
	if type(table) == 'table' then
		local penetration = 0
		for k, v in pairs(table[2]) do
			if v ~= nil then
				penetration = penetration + 1
			end
		end
		if penetration > 0 then
			return true
		else
			return false
		end
	else
		return nil
	end
end

function localScriptMessage(mes, t)
	local sw_mes = {
		[1] = function (marg) slm('* {c41224}[APF]-Error: {d4d4d4}'..marg, COL_DEF) end,
		[2] = function (marg) slm('* {e08f31}[APF]-Warning: {d4d4d4}'..marg, COL_DEF) end,
		[3] = function (marg) slm('* {41a8e8}[APF]-Information: {d4d4d4}'..marg, COL_DEF) end
	}
	sw_mes["err"] = sw_mes[1] sw_mes["warn"] = sw_mes[2] sw_mes["info"] = sw_mes[3]

	if tostring(type(mes)) == 'string' then
		sw_mes[t](mes)
	else
		return nil
	end
end

function doesDirectoryExist(path)
	local tmp = lfs.currentdir()
	local is = lfs.chdir(path) and true or nil
	lfs.chdir(tmp)
	return is
end

function main_init()
	local init_table, tsum, init_result = {}, 0, false
	for f in lfs.dir(mspath) do
		if f ~= '.' or files ~= '..' then
			if f == "load.lua" then init_table["load_module"] = true end
			if f == "language.json" then init_table["language_file"] = true end
		end
	end
	for k, v in pairs(init_table) do
		if v == true then tsum = tsum + 1 end
	end
	if tsum == 2 then init_result = true end

	return init_result, init_table
end

function data_save(mode)
	if mode == 1 or mode == nil then
		jsonConfigSave(ddata, jspath)
		ddata = jsonConfigLoad(jspath)
	elseif mode == 2 then
		jsonConfigSave(ddata, jspath)
		thisScript():reload()
	end
end

function createFileFromUrl(url, path)
	if not io.open(path, 'r') then
		local tfu, err = https.request(url)
		if not tfu then return nil, err end
		local tfh = io.open(path, 'w')
		tfh:write(tfu)
		return true
	else
		return nil, 'Error: '..path..': this file does exist'
	end
end

function downloadScriptFolder()
	if doesDirectoryExist(mspath) then lfs.rmdir(mspath) lfs.mkdir(mspath) end
	for k, v in pairs(sdata["download_url"]) do
		hndl, err = createFileFromUrl(sdata["download_url"][k], mspath..'\\'..k)
		if hndl then
			--return true
		else
			print(err)
			--return err
		end
	end
end

----[============================================> меч епта
-- Имхуй
local ws = {
	['main'] = imgui.ImBool(false)
}

function imgui.OnDrawFrame()
	--local pomt, fmit = mld.init() -- pomt - Path of modules table; fmit - Full module information module
	if ws['main'].v then
		--imgui.ShowTestWindow(ws["main"])
		--imgui.SetNextWindowPos(imgui.ImVec2(1050,635), imgui.Cond.FirstUseEver)
		--imgui.SetNextWindowSize(imgui.ImVec2(300, 100), imgui.Cond.FirstUseEver)
		imgui.Begin(u8(phrases[lang]["window_title"]["main"]), ws['main'])
		--imgui.Text(u8'Test2')
		--imgui.ShowTestWindow(ws['main'])
		imgui.End()
	end
end

----[============================================> меч епта
-- Основной блок
function main()
	while not isSampAvailable() do wait(500) end
	local lsm = localScriptMessage
	if not main_init() then
		reg_cmd('apf/stop', cmd_stop) reg_cmd('apf/reset', cmd_reset)
		if ddata["first_start"] then
			lsm('Спасибо, что скачали скрипт! Надеюсь он вам пригодится ;-) Если это не ваш первый запуск, обратитесь к разработчику: '..sdata["developer_telegram"], "info")
			if downloadScriptFolder() then
				ddata["first_start"] = false
				data_save(2)
			else
				lsm('Проверьте подключение к интернету, и напишите /apf/reset', 'err')
				lsm('Если вы подключены к интернету, а ошибка не проходит обратитесь к разработчику: '..sdata["developer_telegram"], 'err')
			end
		else
			lsm('Если это не ваш первый запуск, и папка скрипта присутствует, то обратитесь к разработчику: '..sdata["developer_telegram"], "err")
			lsm('Также вы можете сбросить настройки, если писать лень или по другой подобной причине. Используйте: /apf/reset <version> (по стандарту самая новая) {b5b5b5}[функционал выбора версии не реализован]', "info")
			slm('* Вы можете либо остановить скрипт (/apf/stop), либо откатить настройки (/apf/reset)', COL_DEF)
			--downloadScriptFolder()
			print('Дебага не будет')
			--lsm('', 'warn')
			--thisScript():unload()
		end
	else
		mld = require('AdvPolFeat.load')
		phrases = jsonConfigLoad(mspath..'\\language.json')
		if ddata["first_start"] then ddata["first_start"] = false data_save() end
		registerCommands()

		local pomt, fmit = mld.init()
		if checkPresenceThirdModules then
			lsm('При инициализации были обнаружены посторонние модули (неофициальные или пользовательские), если вы не уверены в их безопасности, то удалите их.', "warn")
			slm('* {b5b5b5} (увидеть их список можно прописав команду /apf/third)', COL_DEF)
		elseif data["init_message"] == true then
			lsm('Инициализация прошла успешно!', "info")
		end
		while true do
			wait(0)
			imgui.Process = ws['main'].v
		end
	end
end


function registerCommands()
  reg_cmd("apf/gui", function() ws['main'].v = not ws['main'].v end)
	reg_cmd("apf/third", cmd_third)
	reg_cmd("apf/official", cmd_official)
end

function cmd_stop()
	lua_thread.create(function ()
		localScriptMessage('Работа скрипта прекратится через 3 секунды.', 'info')
		wait(3000)
		thisScript():unload()
	end)
end

function cmd_reset(ver) -- Args: <version> [функционал выбора версии не реализован]
	lua_thread.create(function ()
		localScriptMessage('Скрипт будет переустановлен', 'info')
		if downloadScriptFolder() then
			localScriptMessage('Скрипт успешно переустановлен. Через 3 секунды скрипт перезагрузится', 'info')
			for i=1,3 do wait(1000) print(i) end
			thisScript():reload()
		end
	end)
end

function cmd_third()
	local pomt, fmit = mld.init()
	for k, v in pairs(fmit[2]) do
		slm('* Идентификатор стороннего модуля: {f09651}'..k..'{d4d4d4}.', COL_DEF)
		slm('* Путь к нему: {f09651}'..getWorkingDirectory()..'\\'..v[1]:gsub('%.','\\')..'.lua', COL_DEF)
	end
end
