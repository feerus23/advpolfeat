-- EXAMPLE
-- Author: Fuexie
example = {
	_id = 'EXAMPLE', -- DONT CHANGE THIS PARAMETER!!!
	_dlu = 'apf.io/modules/example.lua', -- AND THIS PARAMETER DONT CHANGE!!!
	_author = 'Fuexie'
}

function example.init() -- функция инициализации
	return example._id
end

function example.main() -- основная функция
	return example._id
end

return example
