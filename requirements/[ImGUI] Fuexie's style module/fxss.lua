local _cols = {
	["und"] = {
		bg = {
			theme_name = 'Und',
			w = '2c2428',
			p = '241e21ed',
			t = '382c32', t_a = '3e3037', t_c = '281f23',
			sb = '251e22',
			mb = '32282d',
			f = 'a8365d3c', f_h = 'b3396349', f_a = 'c23b6958',
			txtsel = 'ff448d59'
		},
		text = 'e9b9cd',
		text_disabled = 'b18e9d',
		sb = { m = '45333c80', h = '4a374180', a = '59414d80' },
		btn = 'ce633d', btn_h = 'd56b45', btn_a = 'ec754b',
		header = 'd3546f', header_hovered = 'e15c78', header_active = 'f76785',
		mwd = '2311159D',
		check_mark = 'f0294a'
	}
} _cols[1] = _cols["und"]

local fxss_im = require 'imgui'

local devmode = true

local stl 			= fxss_im.GetStyle()
local c 				= stl.Colors
local clr				= fxss_im.Col
local IV4 			= fxss_im.ImVec4

--[[local ws = {
	['test'] = fxss_im.ImBool(false)
}]]

local function hexToRgb(hex)
  hex = hex:gsub("#","")

	local alpha
	if #hex == 6 then
		alpha = 1.00
	elseif #hex == 8 then
		alpha = tonumber("0x"..hex:sub(7, 8)) / 255
	end

	return {
		r = tonumber("0x"..hex:sub(1,2)) / 255,
		g = tonumber("0x"..hex:sub(3,4)) / 255,
		b = tonumber("0x"..hex:sub(5,6)) / 255,
		a = alpha
	}
end
local cn = hexToRgb

local function fxsstyle(n, win_round, frame_round, chwin_round, scbar_round, grab_round)
	if n == nil then n = 1 end
	--if n > 1 or n < 1 or n ~= 'candy' then return nil, 'argument error. max number themes - 1, min equal too 1' end

	if win_round == nil or win_round < 1 then win_round = 2 end
	if frame_round == nil or frame_round < 1 then frame_round = win_round end
	if chwin_round == nil or chwin_round < 1 then chwin_round = frame_round end
	if scbar_round == nil or scbar_round < 1 then scbar_round = chwin_round end
	if grab_round == nil or grab_round < 1 then grab_round = scbar_round end

	fxss_im.SwitchContext()

	stl.WindowPadding = fxss_im.ImVec2(15.0, 15.0)
	stl.WindowRounding = win_round
	stl.FramePadding = fxss_im.ImVec2(5.0, 5.0)
	stl.FrameRounding = frame_round
	stl.WindowTitleAlign = fxss_im.ImVec2(0.5, 0.84)
	stl.ChildWindowRounding = chwin_round
	stl.ItemSpacing = fxss_im.ImVec2(5.0, 4.0)
	stl.ScrollbarSize = 15.0
	stl.ScrollbarRounding = scbar_round
	stl.GrabMinSize = 5.0
	stl.GrabRounding = grab_round

	local ct = _cols[n]
	local t

	t = cn(ct.text); 										c[clr.Text] 															=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.text_disabled); 					c[clr.TextDisabled] 											=	IV4(t.r,t.g,t.b,t.a)
	--
	t = cn(ct.bg.w); 										c[clr.WindowBg]														=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.bg.f); 										c[clr.FrameBg]														=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.bg.f_h); 									c[clr.FrameBgHovered]											=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.bg.f_a); 									c[clr.FrameBgActive]											=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.bg.p); 										c[clr.PopupBg]														=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.bg.mb); 									c[clr.MenuBarBg]													=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.bg.t); 										c[clr.TitleBg]														=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.bg.t_a);			 						c[clr.TitleBgActive]											=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.bg.t_c);			 						c[clr.TitleBgCollapsed]										=	IV4(t.r,t.g,t.b,t.a)
	--
	t = cn(ct.bg.sb); 									c[clr.ScrollbarBg]												=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.sb.m); 										c[clr.ScrollbarGrab]											=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.sb.h); 										c[clr.ScrollbarGrabHovered]								=	IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.sb.a); 										c[clr.ScrollbarGrabActive]								=	IV4(t.r,t.g,t.b,t.a)
	--
	t = cn(ct.header); 									c[clr.Header] 														= IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.header_hovered); 					c[clr.HeaderHovered] 											= IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.header_active); 					c[clr.HeaderActive] 											= IV4(t.r,t.g,t.b,t.a)
	--
	t = cn(ct.btn); 										c[clr.Button] 														= IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.btn_h); 									c[clr.ButtonHovered] 											= IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.btn_a); 									c[clr.ButtonActive] 											= IV4(t.r,t.g,t.b,t.a)
	--
	t = cn(ct.mwd); 										c[clr.ModalWindowDarkening] 							= IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.bg.txtsel); 							c[clr.TextSelectedBg] 										= IV4(t.r,t.g,t.b,t.a)
	t = cn(ct.check_mark); 							c[clr.CheckMark] 													= IV4(t.r,t.g,t.b,t.a)
	--
	c[clr.CloseButton] = c[clr.Button]
	c[clr.CloseButtonHovered] = c[clr.ButtonHovered]
	c[clr.CloseButtonActive] = c[clr.ButtonActive]

	return ct
end

--[[local function fxss_im.OnDrawFrame()
	if ws['test'].v then
		fxss_im.SetNextWindowPos(fxss_im.ImVec2(650, 20), fxss_im.Cond.FirstUseEver)
		fxss_im.ShowTestWindow(ws['test'])
	end
end

function main()
	if not isSampLoaded() then return end
	sampRegisterChatCommand('/fxss.c', function () devmode = not devmode end)
	sampRegisterChatCommand('/fxss', cmd_fxss)
	while true do
		wait(0)
		fxss_im.Process = true
	end
end

local function cmd_fxss(s)
	if devmode == true then
		if #s == 0 or tonumber(s) > 2 or tonumber(s) < 1 then
			sampAddChatMessage("* [Fx's Styles]: Invalid paramater. Use //fxss <num of style> (1-2)", 0x8989)
		else
			fxsstyle(s)
			ws['test'].v = not ws['test'].v
		end
	end
end]]

return {
	style = fxsstyle,
	version = "1.0-reboot",
	numversion = 2
}
