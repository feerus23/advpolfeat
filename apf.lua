script_name('Advanced Police Features')
script_description('Advanced features for police factions')
script_version('1.0')
script_version_number(1000)
script_author('Fuexie')

local scr = thisScript()
----[============================================> меч епта
local imgui = require'imgui'
local lfs = require'lfs'
local encoding = require'encoding'
local inicfg = require 'inicfg'
local request = require'requests'
local fxs = require'fxss'

encoding.default = 'CP1251'
local u8 = encoding.UTF8

----[============================================> меч епта
-- Всякая хуйня
function siter (s, i)
	if i < #s then i = i + 1 return i, s:sub(i, i) end
end

function chars(s)
	return siter, s, 0
end

function imgui.TextC(text)
  local style = imgui.GetStyle()
  local colors = style.Colors
  local ImVec4 = imgui.ImVec4

  local explode_argb = function(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
  end

  local getcolor = function(color)
    if color:sub(1, 6):upper() == 'SSSSSS' then
      local r, g, b = colors[1].x, colors[1].y, colors[1].z
      local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
      return ImVec4(r, g, b, a / 255)
    end
    local color = type(color) == 'string' and tonumber(color, 16) or color
    if type(color) ~= 'number' then return end
    local r, g, b, a = explode_argb(color)
    return imgui.ImColor(r, g, b, a):GetVec4()
  end

  local render_text = function(text_)
    for w in text_:gmatch('[^\r\n]+') do
      local text, colors_, m = {}, {}, 1
      w = w:gsub('{(......)}', '{%1FF}')
      while w:find('{........}') do
        local n, k = w:find('{........}')
        local color = getcolor(w:sub(n + 1, k - 1))
        if color then
          text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
          colors_[#colors_ + 1] = color
          m = n
        end
        w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
      end
      if text[0] then
          for i = 0, #text do
            imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
            imgui.SameLine(nil, 0)
          end
          imgui.NewLine()
      else imgui.Text(u8(w)) end
    end
  end

  render_text(text)
end

local reg_cmd = sampRegisterChatCommand

local lang_empty = {
	["russian"] = {
		["window_title"] = { },
		["window_content"] = { }
	},
	["english"] = {
		["window_title"] = { },
		["window_content"] = { }
	}
}

local data = {
	["dynamic_data"] = {
		["first_start"] = true, -- by default: true
		["init_message"] = true,
		["main_language"] = "russian",
	},
	["static_data"] = {
		["main_path"] = getWorkingDirectory()..'\\AdvPolFeat',
		["json_settings_path"] = getWorkingDirectory()..'\\AdvPolFeat\\json\\settings.json',
		["json_folder_path"] = getWorkingDirectory()..'\\AdvPolFeat\\json',
		["colors"] = {
			["default"] = 0xD4D4D4
		},
		["download_url"] = {
			["load.lua"] = "https://raw.githubusercontent.com/fuexie/advpolfeat/master/build/AdvPolFeat/load.lua",
			["language.json"] = "https://raw.githubusercontent.com/fuexie/advpolfeat/master/build/AdvPolFeat/json/language.json"
		},
		["developer_telegram"] = "t.me/fuexie"
	}
}

local dyn_data = data["dynamic_data"]
local sdata = data["static_data"]
local mspath = sdata["main_path"]
local jspath = sdata["json_settings_path"]
local jpath = sdata["json_folder_path"]

local COL_DEF = sdata["colors"]["default"]

function jsonConfigSave(tab, path)
	local f, err = io.open(path, 'w')
	if not f then
		return nil, err
	end
	local tbl = require'json'.encode(tab)
	f:write(tbl) f:close()
	return true
end

function jsonConfigLoad(path, tab)
	if tab == nil then tab = dyn_data end
	local f, err = io.open(path, 'r')
	if not f then
		if not doesDirectoryExist(mspath) then
			lfs.mkdir(mspath)
			if not doesDirectoryExist(jpath) then lfs.mkdir(jpath) end
		end
		local jfle = io.open(path, 'w')
		local tbl = require'json'.encode(tab)
		jfle:write(tbl)
		jfle:close()
		return tab
	else
		local cfg = f:read('*a')
		f:close()
		return require'json'.decode(cfg)
	end
end

local ddata = jsonConfigLoad(jspath, dyn_data)
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

function internetConnetcion ()
	local resp = request.get("https://www.google.com/")
	if not resp.text then
		return nil, resp.code
	else
		return true, nil
	end
end

function table.empty(self)
    for _ in pairs(self) do
        return false
    end
    return true
end

function checkPresenceThirdModules(tab)
	if type(tab) == 'table' then
		if table.empty(tab) then
			return false
		else
			return true
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
		if f ~= '.' or f ~= '..' then
			--print(f)
			if f == "load.lua" then init_table["load_module"] = true end
		end
	end
	for f in lfs.dir(jpath) do
		if f == "language.json" then init_table["language_file"] = true end
	end
	for k, v in pairs(init_table) do
		if v == true then tsum = tsum + 1 end
	end
	if tsum == 2 then init_result = true end

	--print(init_result, init_table)
	return init_result, init_table
end

function data_save(mode)
	if mode == 1 or mode == nil then
		jsonConfigSave(ddata, jspath)
		ddata = jsonConfigLoad(jspath)
	elseif mode == 2 then
		jsonConfigSave(ddata, jspath)
		scr:reload()
	end
end

function createFileFromUrl(url, path)
	local download_start = function (u, p)
		local resp = request.get(u)
		if not resp.text then return nil, resp.code, 1 end
		local tfh = io.open(p, 'w')
		tfh:write(resp.text)
		return true
	end
	if not io.open(path, 'r') then
		return download_start(url, path)
	else
		os.execute('DEL '..path)
		return download_start(url, path)
		--return nil, 'Error: '..path..': this file does exist', 2
	end
end

function downloadScriptFolder()
	local errs = {}
	local fcount = 0
	if doesDirectoryExist(mspath) then
		lfs.rmdir(mspath)
		lfs.mkdir(mspath) lfs.mkdir(mspath..'\\modules')
	end
	for k, v in pairs(sdata["download_url"]) do
		if k:find('.json') then
			hndl, err = createFileFromUrl(sdata["download_url"][k], jpath..'\\'..k)
		else
			hndl, err = createFileFromUrl(sdata["download_url"][k], mspath..'\\'..k)
		end
		if hndl then
			fcount = fcount + 1
			--return true
		else
			table.insert(errs, v..': '..err)
			--return err
		end
	end
	if fcount == 2 then
		return true
	else
		return false, errs
	end
end

function getThirdModulesList(tbl)
	local tmp = { }
	if checkPresenceThirdModules(tbl) then
		for k, v in pairs(tbl) do
			table.insert(tmp, { k, getWorkingDirectory()..'\\'..v[1]:gsub('%.','\\')..'.lua' })
		end
		return tmp
	else
		return nil, 'third modules doesnt prescence'
	end
end

function getTModsListString()
	local tbl = getThirdModulesList(fmit[2])
	local tmp = ''
	for i, v in pairs(tbl) do
		tmp = tmp..'\n***\nModule name: {f0294a}'..v[1]..'{'..style.text..'}'..'. \nPath to module: {f0294a}'..v[2]..'{'..style.text..'}'..';'
	end
	return tmp
end

function chatSeperator(ty)
	local seperator_types = {
		[1] = '=========================================================',
		[2] = '~==================== [ ADVPOLFEAT ] ====================~',
		[3] = '*\n*\n*'
	}
	if ty < 1 or ty > 3 then
		return nil
	else
		sampAddChatMessage(seperator_types[ty], -1)
	end
end

local phrases = jsonConfigLoad(jpath..'\\language.json', lang_empty)
local wintit = phrases[lang]["window_title"]
local wincon = phrases[lang]["window_content"]
local first_imgui_start, tm_showed = true, false
local str = { }

----[============================================> меч епта
-- подгрузка модулей
local mods = {}
mods.list = {}
mods.thread = {}

function mods.Requireing()
	local tmp = require('AdvPolFeat.load').init()
	for k, v in pairs(tmp[1]) do
		mods.list[#mods.list+1] = require(v)
	end
	for k, v in pairs(tmp[2]) do
		mods.list[#mods.list+1] = require(v)
	end
	if #mods.list == #tmp[2] + #tmp[1] then
		return true
	else
		return nil
	end
end

function mods.Run()
	for i, v in ipairs(mods.list) do
		mods.thread[i] = lua_thread.create(mods.Process, v)
	end
end

function mods.Process(mod)
	local me = mod.main(scr.version)
	while true do
		wait(0)
		me()
	end
end

function mods.Stop()
	for i, v in ipairs(mods.list) do
		mods.thread[i]:terminate()
	end
end

function mods.Reload()
	mods.Stop()
	mods.list = {}
	require('AdvPolFeat.load').reload()
	mods.Requireing()
	mods.Run()
end

----[============================================> меч епта
-- имхуй
local ws = {
	['start'] = imgui.ImBool(false),
	['main'] = imgui.ImBool(false),
	['tmd'] = imgui.ImBool(false)
}

function imgui.OnDrawFrame()
	if ws['main'].v then
		imgui.Begin(u8(wintit["main"]), ws['main'])
		imgui.Text(u8(wincon["main"]))
		imgui.End()
	end
	if ws['tmd'].v then
		local tml = getTModsListString()
		str[1] = string.format(wincon["tmd"], style.text, tml)
		imgui.Begin(u8(wintit["tmd"]), ws['tmd'])
		imgui.TextC(str[1])
		imgui.End()
	end
end

----[============================================> меч епта
-- Основной блок
function main()
	while not isSampAvailable() do wait(500) end
	local lsm = localScriptMessage
	local inCon, err = internetConnetcion()
	if not main_init() then
		reg_cmd('apf/stop', cmd_stop) reg_cmd('apf/reset', cmd_reset)
		if ddata["first_start"] then
			if inCon then
				lsm('Спасибо, что скачали скрипт! Надеюсь он вам пригодится ;-) Если это не ваш первый запуск, обратитесь к разработчику: '..sdata["developer_telegram"], "info")
				ddata["first_start"] = false
				data_save(2)
			else
				lsm('У вас отсуствтует подключение к интернету. Без него установка скрипта невозможна.', 'err')
			end
		else
			if inCon then
				lsm('Если это не ваш первый запуск, и папка скрипта присутствует, то обратитесь к разработчику: '..sdata["developer_telegram"], "err")
				lsm('Также вы можете сбросить настройки, если писать лень или по другой подобной причине. Используйте: /apf/reset <version> (по стандарту самая новая) {b5b5b5}[функционал выбора версии не реализован]', "info")
				slm('* Вы можете либо остановить скрипт (/apf/stop), либо откатить настройки (/apf/reset)', COL_DEF)
				--downloadScriptFolder()
				print('Дебага не будет')
				--lsm('', 'warn')
				--thisScript():unload()
			else
				lsm('Проверьте подключение к интернету, и напишите /apf/reset', 'err')
				lsm('Если вы подключены к интернету, а ошибка не проходит обратитесь к разработчику: '..sdata["developer_telegram"], 'err')
			end
		end
	else
		print('main_init succesfuly finished.')
		style = fxs.style(1, 9, 3)
		mld = require('AdvPolFeat.load')
		if ddata["first_start"] then ddata["first_start"] = false data_save() end
		registerCommands()

		if inCon then
			pomt, fmit = mld.init()
			if checkPresenceThirdModules(pomt[2]) then
				lsm('При инициализации были обнаружены посторонние модули (неофициальные или пользовательские), если вы не уверены в их безопасности, то удалите их.', "warn")
				slm('* {b5b5b5} (увидеть их список можно прописав команду /apf/third)', COL_DEF)
			elseif ddata["init_message"] == true then
				lsm('Инициализация прошла успешно!', "info")
			end
			while true do
				wait(0)
				imgui.Process = ws['main'].v or ws['tmd'].v
			end
		else
			lsm('Отсутствует подключение к интернету', 'err')
			print(err)
		end
	end
end


function registerCommands()
	reg_cmd("apf", cmd_help)
	reg_cmd("apf/help", cmd_help)
  reg_cmd("apf/gui", cmd_gui)
	reg_cmd("apf/third", cmd_third)
	reg_cmd("apf/official", cmd_official)
end

function cmd_gui()
	if checkPresenceThirdModules(pomt[2]) and first_imgui_start then
		first_imgui_start = false
		lua_thread.create(
		function ()
			ws['tmd'].v = true
			while ws['tmd'].v do
				wait(0)
			end
			ws['main'].v = true
		end)
	else
		if ws['tmd'].v == true then ws['tmd'].v = false end
		ws['main'].v = not ws['main'].v
	end
end

function cmd_stop()
	lua_thread.create(function ()
		localScriptMessage('Скрипт будет остановлен через 3 секунды.', 'info')
		wait(3000)
		thisScript():unload()
	end)
end

function cmd_reset(ver) -- Args: <version> [функционал выбора версии не реализован]
	lua_thread.create(function ()
		localScriptMessage('Скрипт будет переустановлен', 'info')
		local h, errs = downloadScriptFolder()
		if h then
		localScriptMessage('Скрипт успешно переустановлен. Через 3 секунды скрипт перезагрузится', 'info')
			thisScript():reload()
		else
			localScriptMessage('Проверьте подключение к интернету', 'err')
			for _, v in ipairs(errs) do
				print(v)
			end
		end
	end)
end

function cmd_third()
	local tmp = getThirdModulesList(fmit[2])
	if not tmp then
		localScriptMessage('Посторонних модулей не обнаружено!', 'info')
	else
		for i, v in ipairs(tmp) do
			chatSeperator(3)
			slm('* Идентификатор стороннего модуля: {f09651}'..v[1]..'{d4d4d4}.', COL_DEF)
			slm('* Путь к нему: {f09651}'..v[2], COL_DEF)
			chatSeperator(3)
		end
	end
end
