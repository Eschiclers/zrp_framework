ZRP = {}
ZRP.Players = {}
ZRP.Items = {}
ZRP.ServerCallbacks = {}
ZRP.UsableItemsCallbacks = {}
ZRP.Pickups = {}
ZRP.PickupId = 0
ZRP.RegisteredCommands = {}

AddEventHandler('zrp:getSharedObject', function(cb)
	cb(ZRP)
end)

function getSharedObject()
	return ZRP
end

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
		for k,v in ipairs(result) do
			ZRP.Items[v.name] = {
				label = v.label,
				weight = v.weight,
				rare = v.rare,
				canRemove = v.can_remove
			}
		end
		print(('[zrp_framework] [^2INFO^7] %s Items loaded'):format(#result))
	end)
end)

RegisterServerEvent('zrp_framework:triggerServerCallback')
AddEventHandler('zrp_framework:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	ZRP.TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('zrp_framework:serverCallback', playerId, requestId, ...)
	end, ...)
end)