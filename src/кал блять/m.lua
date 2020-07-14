
local k, v, mer, cou = {}, {}, {}, 0
local function tableSearch(tab, val, col)
	if col > 1 then
		if type(val) == 'table' then
			
		else
		end
	else
		if col =< 0 and col ~= nil then
			return 'error: counts of levels =< 0'
		else
			for k, v in pairs(tab) do
				if val == v then cou = cou + 1 table.insert(mer, k) end
			end
			if cou < 1 then return nil else return cou, mer
		end
	end
end