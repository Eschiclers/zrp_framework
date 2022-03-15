AddEventHandler('zrp:getSharedObject', function(cb)
	cb(ZRP)
end)

function getSharedObject()
	return ZRP
end