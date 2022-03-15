ZRP = {}
ZRP.PlayerData = {}
ZRP.PlayerLoaded= false
ZRP.CurrentRequestId = 0
ZRP.ServerCallbacks = {}
ZRP.TimeoutCallbacks = {}

ZRP.Game = {}

ZRP.SetTimeout = function(msec, cb)
	table.insert(ZRP.TimeoutCallbacks, {cb = cb, time = GetGameTimer() + msec})
	return #ZRP.TimeoutCallbacks
end

ZRP.ClearTimeout = function(i)
	ZRP.TimeoutCallbacks[i] = nil
end

ZRP.IsPlayerLoaded = function()
	return ZRP.PlayerLoaded
end

ZRP.GetPlayerData = function()
	return ZRP.PlayerData
end

ZRP.SetPlayerData = function(key, val)
	ZRP.PlayerData[key] = val
end

ZRP.TriggerServerCallback = function(name, cb, ...)
	ZRP.ServerCallbacks[ZRP.CurrentRequestId] = cb

	TriggerServerEvent('zrp_framework:triggerServerCallback', name, ZRP.CurrentRequestId, ...)

	if ZRP.CurrentRequestId < 65535 then
		ZRP.CurrentRequestId = ZRP.CurrentRequestId + 1
	else
		ZRP.CurrentRequestId = 0
	end
end

ZRP.Game.Teleport = function(entity, coords, cb)
	if DoesEntityExist(entity) then
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		local timeout = 0

		-- we can get stuck here if any of the axies are "invalid"
		while not HasCollisionLoadedAroundEntity(entity) and timeout < 2000 do
			Citizen.Wait(0)
			timeout = timeout + 1
		end

		SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)

		if type(coords) == 'table' and coords.heading then
			SetEntityHeading(entity, coords.heading)
		end
	end

	if cb then
		cb()
	end
end