script_name('Advanced Police Features')
script_description('Advanced features for police factions')
script_version('0.9')
script_version_number(0900)
script_author('Fuexie')
----[============================================> меч епта
local imgui = require'imgui'
local lfs = require'lfs'

local mld = require('AdvPolFeat.load')

----[============================================> меч епта
-- Всякая хуйня
function siter (s, i)
	if i < #s then i = i + 1 return i, s:sub(i, i) end
end

function chars(s)
	return siter, s, 0
end

local reg_cmd = sampRegisterChatCommand

local data = {
	["init_message"] = true,
	["colors"] = {
		["default"] = 0xD4D4D4
	}
}

local COL_DEF = data["colors"]["default"]

function slm(mes, col1, col2)
	local col_braces = false
	tmp = mes:gsub("({[a-zA-Z0-9]+})","")
	if #tmp > 107 then
		local large_mes, line, counter = {}, 1, 0
		for _, c in chars(mes) do
			--print(c)
			if c:match("{") then col_braces = true end
			if c:match("}") then col_braces = false end
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
		return sampAddChatMessage(mes, col)
	end
end

function localScriptMessage(mes, t)
	if tostring(type(mes)) == 'string' then
		local sw_mes = {
			[1] = function (marg) slm('* {a61738}[APF]-Error: {d4d4d4}'..marg, COL_DEF) end,
			[2] = function (marg) slm('* {e08f31}[APF]-Warning: {d4d4d4}'..marg, COL_DEF) end,
			[3] = function (marg) slm('* {41a8e8}[APF]-Information: {d4d4d4}'..marg, COL_DEF) end
		}
		sw_mes["err"] = sw_mes[1] sw_mes["warn"] = sw_mes[2] sw_mes["info"] = sw_mes[3]
		sw_mes[t](mes)
	else
		return nil
	end
end
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
function main()
	local lsm = localScriptMessage
  registerCommands()

	local pomt, fmit = mld.init()
	local penetration = 0
	for k, v in pairs(pomt[2]) do if v ~= nil then penetration = penetration + 1 end end
	if penetration ~= 0 then
		lsm('Осторожно! При инициализации обнаружены посторонние модули, если вы не уверены в их безопасности, то удалите их.', "warn")
	elseif data["init_message"] == true then
		lsm('Инициализация прошла успешно.', "info")
	end

  while true do
    wait(0)
    --imgui.Process = true
  end
end


function registerCommands()
  reg_cmd("apf/gui", function() ws['main'].v = not ws['main'].v end)
end
