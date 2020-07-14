-- EXAMPLE
-- Author: Fuexie
tpm = {
	_id = 'THIRD-PARTY-MODULE', -- DONT CHANGE THIS PARAMETER!!!
	_dlu = 'apf.io/modules/third.lua', -- AND THIS PARAMETER DONT CHANGE!!!
	_author = 'Fuexie'
}

function tpm.init()
	return tpm._id
end

return tpm
