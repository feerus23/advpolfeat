local XPRT = {
	_AUTHORS = {
		'Fuexie'
	},
	_VERSION = '1.1'
}
package.path = package.path..';C:\\repos\\apf\\src\\lib\\?.lua'
package.cpath = package.cpath..';C:\\repos\\apf\\src\\lib\\?.dll'

local lfs = require'lfs'
local https = require('ssl.https')

local json_url = 'https://raw.githubusercontent.com/fuexie/advpolfeat/master/data/modules_list.json'

local function jsonRead(text)
	return require('json').decode(text)
end

local function lmd()
  local md = {}

  for file in lfs.dir('modules\\') do
    if file ~= '.' and file ~= '..' then
      local fgs = file:gsub('.lua','')
      local path = 'modules.'..fgs
      local m = require(path)
      if m._id ~= nil then
        md[m._id] = { path, m._dlu, m._author }
      end
    end
  end
  return md
end

local function rmd()
  local md = {}

  local b, c, h, s = https.request(json_url)
  if not b then
    print(c)
  else
    for k, v in pairs(jsonRead(b)) do
      md[k] = v
    end
  end
  return md
end


local function loadMods()
  local l, r = lmd(), rmd()
  local official, third, undwn = {}, {}, {}

  for k, v in pairs(l) do
    local matches = 0
    for k2, v2 in pairs(r) do
      if k == k2 and v[1] == v2[1] and v[2] == v2[2] and v2[3] == v2[3] then
        matches = matches + 1
      end
    end
    if matches > 0 then official[k] = v else third[k] = v end
  end

	for k, v in pairs(r) do
		local matches = 0
		for k2, v2 in pairs(l) do
			if k == k2 and v[1] == v2[1] and v[2] == v2[2] and v[3] == v2[3] then
				matches = matches + 1
			end
		end
		if matches == 0 then undwn[k] = v end
	end

  return official, third, undwn
end

function XPRT.init()
  local of, th, un = loadMods()


  for k, v in pairs(th) do
    print(k..' : '..v[1]..' ; '..v[2]..' ; '..v[3])
  end
end

XPRT.init()
