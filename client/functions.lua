ZRP = {}
ZRP.PlayerData = {}
ZRP.PlayerLoaded= false
ZRP.CurrentRequestId = 0
ZRP.ServerCallbacks = {}
ZRP.TimeoutCallbacks = {}

ZRP.Game = {}

ZRP.Streaming = {}

function ZRP.Streaming.RequestModel(modelHash, cb)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function ZRP.Streaming.RequestStreamedTextureDict(textureDict, cb)
	if not HasStreamedTextureDictLoaded(textureDict) then
		RequestStreamedTextureDict(textureDict)

		while not HasStreamedTextureDictLoaded(textureDict) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function ZRP.Streaming.RequestNamedPtfxAsset(assetName, cb)
	if not HasNamedPtfxAssetLoaded(assetName) then
		RequestNamedPtfxAsset(assetName)

		while not HasNamedPtfxAssetLoaded(assetName) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function ZRP.Streaming.RequestAnimSet(animSet, cb)
	if not HasAnimSetLoaded(animSet) then
		RequestAnimSet(animSet)

		while not HasAnimSetLoaded(animSet) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function ZRP.Streaming.RequestAnimDict(animDict, cb)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function ZRP.Streaming.RequestWeaponAsset(weaponHash, cb)
	if not HasWeaponAssetLoaded(weaponHash) then
		RequestWeaponAsset(weaponHash)

		while not HasWeaponAssetLoaded(weaponHash) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

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

ZRP.Game.SpawnVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		ZRP.Streaming.RequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
		local networkId = NetworkGetNetworkIdFromEntity(vehicle)
		local timeout = 0

		SetNetworkIdCanMigrate(networkId, true)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetVehRadioStation(vehicle, 'OFF')
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		-- we can get stuck here if any of the axies are "invalid"
		while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 2000 do
			Citizen.Wait(0)
			timeout = timeout + 1
		end

		if cb then
			cb(vehicle)
		end
	end)
end

ZRP.Game.DeleteVehicle = function(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end

ZRP.Game.GetObjects = function()
	local objects = {}

	for object in EnumerateObjects() do
		table.insert(objects, object)
	end

	return objects
end

ZRP.Game.GetPeds = function(onlyOtherPeds)
	local peds, myPed = {}, PlayerPedId()

	for ped in EnumeratePeds() do
		if ((onlyOtherPeds and ped ~= myPed) or not onlyOtherPeds) then
			table.insert(peds, ped)
		end
	end

	return peds
end

ZRP.Game.GetVehicles = function()
	local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

	return vehicles
end

ZRP.Game.GetPlayers = function(onlyOtherPlayers, returnKeyValue, returnPeds)
	local players, myPlayer = {}, PlayerId()

	for k,player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)

		if DoesEntityExist(ped) and ((onlyOtherPlayers and player ~= myPlayer) or not onlyOtherPlayers) then
			if returnKeyValue then
				players[player] = ped
			else
				table.insert(players, returnPeds and ped or player)
			end
		end
	end

	return players
end

ZRP.Game.GetClosestObject = function(coords, modelFilter) return ZRP.Game.GetClosestEntity(ZRP.Game.GetObjects(), false, coords, modelFilter) end
ZRP.Game.GetClosestPed = function(coords, modelFilter) return ZRP.Game.GetClosestEntity(ZRP.Game.GetPeds(true), false, coords, modelFilter) end
ZRP.Game.GetClosestPlayer = function(coords) return ZRP.Game.GetClosestEntity(ZRP.Game.GetPlayers(true, true), true, coords, nil) end
ZRP.Game.GetClosestVehicle = function(coords, modelFilter) return ZRP.Game.GetClosestEntity(ZRP.Game.GetVehicles(), false, coords, modelFilter) end
ZRP.Game.GetPlayersInArea = function(coords, maxDistance) return EnumerateEntitiesWithinDistance(ZRP.Game.GetPlayers(true, true), true, coords, maxDistance) end
ZRP.Game.GetVehiclesInArea = function(coords, maxDistance) return EnumerateEntitiesWithinDistance(ZRP.Game.GetVehicles(), false, coords, maxDistance) end
ZRP.Game.IsSpawnPointClear = function(coords, maxDistance) return #ZRP.Game.GetVehiclesInArea(coords, maxDistance) == 0 end

ZRP.Game.GetVehicleInDirection = function()
	local playerPed    = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local inDirection  = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
	local rayHandle    = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	if hit == 1 and GetEntityType(entityHit) == 2 then
		return entityHit
	end

	return nil
end