local XPRT = {
	_AUTHORS = {
		'Fuexie'
	},
	_VERSION = '1.1'
}
package.path = package.path..';C:\\repos\\apf\\src\\lib\\?.lua'
package.cpath = package.cpath..';C:\\repos\\apf\\src\\lib\\?.dll'
local lfs = require'lfs'
local sock = require('socket')
local http = require('socket.http')
local https = require('ssl.https')

local json_url = 'https://raw.githubusercontent.com/fuexie/advpolfeat/master/data/modules_list.json'

local modules = {}
do
	function modules:initModule(path)
		local obj = {}
		if #tostring(name) ~= 0 then obj[#obj+1] = { path } end

		function obj:setModuleIdent(id)
			for i, v in ipairs(obj) do
				if v[1] == path then table.insert(obj[i], id) end
			end
		end

		function obj:setModuleDownloadURL(url)
			for i, v in ipairs(obj) do
				if v[1] == path then table.insert(obj[i], url) end
			end
		end

		function obj:getModulePath()
			return path
		end

		function obj:getModuleDownloadURL()
			for i, v in ipairs(obj) do
				if v[1] == path then return v[3] end
			end
		end

		function obj:getModuleIdent()
			for i, v in ipairs(obj) do
				if v[1] == path then return v[2] end
			end
		end

		function obj:registerModule()
			return require(path)
		end

		function obj:removeModule()
			for k, v in pairs(obj) do if v == path then table.remove(obj,k) end end
		end

		self.__index = self
		return setmetatable(obj, self)
	end
end

local function jsonRead(text)
	return require('lib.json').decode(text)
end

local function localModules()
	--io.open(path, 'r'):read('*a')
	local tlst = {}
	for file in lfs.dir('modules\\') do
		if file ~= '.' and file ~= '..' then
			local fgs = file:gsub('.lua','')
			tlst[#tlst+1] = modules:initModule('modules.'..fgs)
			local tarr = tlst[#tlst]
			local trm = tarr:registerModule()
			if trm._id == nil then
				tarr:removeModule()
			else
				tarr:setModuleIdent(trm._id)
				tarr:setModuleDownloadURL(trm._dlu)
			end
		end
	end
	return tlst
end

local function remoteModules()
	local tlst = {}
	local b, c, h, s = https.request(json_url)
	if not b then
		print(c)
	else
		for k, v in pairs(jsonRead(b)) do
			tlst[#tlst+1] = modules:initModule(v[1])
			local tarr = tlst[#tlst]
			tarr:setModuleIdent(k)
			tarr:setModuleDownloadURL(v[2])
		end
		return tlst
	end
end

--[[local function tabElEx(tab, val, i)
	if type(tab) == 'table' then
		if i == nil then i = 0 end
		i = i + 1
		--
		if type(tab[i]) == 'table' then
			hash = false
			return tabElEx(tab[i], val)
		else
			if hash == false then i = 1 hash = true end
			if tab[i] ~= val then
				if i ~= #tab then
					return tabElEx(tab, val, i)
				else
					return false
				end
			else
				return true
			end
		end
	else
		if tab == val then return true else return nil end
	end
end]]

local function tabElEx(tab, val)
	local rv = false
	for i, v in ipairs(tab) do
		if type(v) == 'table' then
			tabElEx(v, val)
		else
			if v == val then
				rv = true
			else
				if i ~= #tab then rv = false end
			end
		end
	end
	return rv
end

function XPRT.loadModules()

	local me, he, hash, here, there = {}, {}, {}, localModules(), remoteModules()

	local nxps = remoteModules()
	for _, v in ipairs(here) do
		table.insert(nxps, v)
	end

	for _, v in ipairs(nxps) do
		local GMP = v.getModulePath()
		if hash[GMP] == nil then
			me[#me+1] = v
			hash[GMP] = 1
		end
	end

	return me, here, there
end

local function p(var, num)
	if num == nil then var = var + 1 else var = var + num end
	return var
end

function XPRT.init()
	local _, _l, _r = XPRT.loadModules()
	local guseong = { _l, _r }
	local bongwan = { {}, {} }

	for i = 1, 2 do
		for _, v in ipairs(guseong[i]) do
			bongwan[i][#bongwan[i]+1] = { v.getModuleIdent(), v.getModulePath(), v.getModuleDownloadURL() }
		end
	end

	local ms = { {}, {}, {} }
	for _, v in ipairs(bongwan[1]) do
		local matches = 0
		for _, w in ipairs(bongwan[2]) do
			if v[1] == w[1] then matches = matches + 1 end
		end
		if matches > 0 then table.insert(ms[1], v) end
	end

	for _, v in ipairs(ms[1]) do
		for _, w in ipairs(v) do print(w) end
	end

	return bongwan, guseong
end

XPRT.init()



return XPRT
