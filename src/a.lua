local mt = {
	__call = function(self,name)
		self.name = name; return self
	end
}

local character = setmetatable({},mt)

function character:getName()
	return self.name
end

local m = character('MAXIS')

print(m:getName())