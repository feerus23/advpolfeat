local function jsonRead(path)
	local json = require 'lib.json'

	local file = io.open(path, 'r')
	local json_file = file:read()
	local content = json.decode(json_file)

	--for k, v in pairs(content) do
	--	print('Key: '..k..'Value: '..v)
	--end
	return content
end

