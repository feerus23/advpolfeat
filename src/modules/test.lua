-- EXAMPLE
-- Author: Fuexie
test = {
	_id = 'TEST', -- DONT CHANGE THIS PARAMETER!!!
	_dlu = 'apf.io/modules/test.lua', -- AND THIS PARAMETER DONT CHANGE!!!
	_author = 'Fuexie'
}

function test.init()
	return test._id
end

return test
