local XPRT = {
	_AUTHORS = {
		'Fuexie'
	},
	_VER = '2.0' -- Быдловерсия
}

local lfs = require'lfs'
local https = require'https'

local json_url = 'https://raw.githubusercontent.com/fuexie/advpolfeat/master/data/modules_list.json'
package.path = package.path..';'..getWorkingDirectory()..'\\AdvPolFeat\\modules\\?.Lua'

function jsonRead(text)
	return require('json').decode(text)
end

function ebanutiyVariant(str)
	return str:gsub('%.lua','') or str:gsub('%.Lua','') or str:gsub('%.LUA','')
end

function XPRT.lmd()
  local md = {}

  for file in lfs.dir(getWorkingDirectory()..'\\AdvPolFeat\\modules\\') do
    if file ~= '.' and file ~= '..' then
			--print(file)
			if string.match(string.upper(file), '%.LUA') and not file:match('ignore') then
	      local fgs = file:gsub('%.[lua]*[Lua]*[LUA]*','')
	      local path = 'AdvPolFeat.modules.'..fgs
	      local m = require(path)
	      if m._id ~= nil then
	        md[m._id] = { path, m._dlu, m._author }
	      end
				--print(md[m._id][1])
			end
    end
  end
  return md
end

function XPRT.rmd()
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


function loadMods()
  local l, r = XPRT.lmd(), XPRT.rmd()
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
	local full_modules_information_table = {}
	full_modules_information_table[1], full_modules_information_table[2], full_modules_information_table[3] = loadMods()
	path_of_modules_table = { {}, {}, {} }

	for i = 1, 3 do
	  for k, v in pairs(full_modules_information_table[i]) do
			table.insert(path_of_modules_table[i], v[1])
	    --print(k..' : '..v[1]..' ; '..v[2]..' ; '..v[3])
	  end
	end

	return path_of_modules_table, full_modules_information_table
end

function XPRT.reload()
	local o, t, u = XPRT.init()
	return o, t, u
end

--XPRT.init()

return XPRT
