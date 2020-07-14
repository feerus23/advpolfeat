local file = io.open('test.txt', 'r')

local lne = 3 -- Номер нужной тебе строки
local i = 0
for line in file:lines() do
	i = i + 1
	if i == lne then print(line) end
end
