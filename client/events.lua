RegisterNetEvent('zrp_framework:playerLoaded')
AddEventHandler('zrp_framework:playerLoaded', function(playerData)
	ZRP.PlayerLoaded = true
	ZRP.PlayerData = playerData

	-- check if player is coming from loading screen
	if GetEntityModel(PlayerPedId()) == GetHashKey('PLAYER_ZERO') then
		local defaultModel = GetHashKey('s_m_y_ranger_01')
		RequestModel(defaultModel)

		while not HasModelLoaded(defaultModel) do
			Citizen.Wait(10)
		end

		SetPlayerModel(PlayerId(), defaultModel)
		SetPedDefaultComponentVariation(PlayerPedId())
		SetPedRandomComponentVariation(PlayerPedId(), true)
		SetModelAsNoLongerNeeded(defaultModel)
	end

	-- freeze the player
	FreezeEntityPosition(PlayerPedId(), true)

	-- enable PVP
	SetCanAttackFriendly(PlayerPedId(), true, false)
	NetworkSetFriendlyFireOption(true)

	-- disable wanted level
	ClearPlayerWantedLevel(PlayerId())
	SetMaxWantedLevel(0)

	ZRP.Game.Teleport(PlayerPedId(), {
		x = playerData.coords.x,
		y = playerData.coords.y,
		z = playerData.coords.z + 0.25,
		heading = playerData.coords.heading
	}, function()
		TriggerServerEvent('zrp_framework:onPlayerSpawn')
		TriggerEvent('zrp_framework:onPlayerSpawn')
		TriggerEvent('zrp_framework:restoreLoadout')

		Citizen.Wait(4000)
		ShutdownLoadingScreen()
		ShutdownLoadingScreenNui()
		FreezeEntityPosition(PlayerPedId(), false)
		DoScreenFadeIn(10000)
		StartServerSyncLoops()
	end)

	TriggerEvent('zrp_framework:loadingScreenOff')
end)

function StartServerSyncLoops()
	-- keep track of ammo
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)

			if isDead then
				Citizen.Wait(500)
			else
				local playerPed = PlayerPedId()

				if IsPedShooting(playerPed) then
					local _,weaponHash = GetCurrentPedWeapon(playerPed, true)
					local weapon = ZRP.GetWeaponFromHash(weaponHash)

					if weapon then
						local ammoCount = GetAmmoInPedWeapon(playerPed, weaponHash)
						TriggerServerEvent('zrp_framework:updateWeaponAmmo', weapon.name, ammoCount)
					end
				end
			end
		end
	end)

	-- sync current player coords with server
	Citizen.CreateThread(function()
		local previousCoords = vector3(ZRP.PlayerData.coords.x, ZRP.PlayerData.coords.y, ZRP.PlayerData.coords.z)

		while true do
			Citizen.Wait(1000)
			local playerPed = PlayerPedId()

			if DoesEntityExist(playerPed) then
				local playerCoords = GetEntityCoords(playerPed)
				local distance = #(playerCoords - previousCoords)

				if distance > 1 then
					previousCoords = playerCoords
					local playerHeading = ZRP.Math.Round(GetEntityHeading(playerPed), 1)
					local formattedCoords = {x = ZRP.Math.Round(playerCoords.x, 1), y = ZRP.Math.Round(playerCoords.y, 1), z = ZRP.Math.Round(playerCoords.z, 1), heading = playerHeading}
					TriggerServerEvent('zrp_framework:updateCoords', formattedCoords)
				end
			end
		end
	end)
end

AddEventHandler('zrp_framework:restoreLoadout', function()
	local playerPed = PlayerPedId()
	local ammoTypes = {}
	RemoveAllPedWeapons(playerPed, true)

	for k,v in ipairs(ZRP.PlayerData.loadout) do
		local weaponName = v.name
		local weaponHash = GetHashKey(weaponName)

		GiveWeaponToPed(playerPed, weaponHash, 0, false, false)
		SetPedWeaponTintIndex(playerPed, weaponHash, v.tintIndex)

		local ammoType = GetPedAmmoTypeFromWeapon(playerPed, weaponHash)

		for k2,v2 in ipairs(v.components) do
			local componentHash = ZRP.GetWeaponComponent(weaponName, v2).hash
			GiveWeaponComponentToPed(playerPed, weaponHash, componentHash)
		end

		if not ammoTypes[ammoType] then
			AddAmmoToPed(playerPed, weaponHash, v.ammo)
			ammoTypes[ammoType] = true
		end
	end
end)

RegisterNetEvent('zrp_framework:serverCallback')
AddEventHandler('zrp_framework:serverCallback', function(requestId, ...)
	ZRP.ServerCallbacks[requestId](...)
	ZRP.ServerCallbacks[requestId] = nil
end)

RegisterNetEvent('zrp_framework:setMaxWeight')
AddEventHandler('zrp_framework:setMaxWeight', function(newMaxWeight) 
  ZRP.PlayerData.maxWeight = newMaxWeight 
end)

AddEventHandler('zrp_framework:onPlayerSpawn', function() 
  isDead = false 
end)

AddEventHandler('zrp_framework:onPlayerDeath', function() 
  isDead = true 
end)

RegisterNetEvent('zrp_framework:teleport')
AddEventHandler('zrp_framework:teleport', function(coords)
	local playerPed = PlayerPedId()

	-- ensure decmial number
	coords.x = coords.x + 0.0
	coords.y = coords.y + 0.0
	coords.z = coords.z + 0.0

	ZRP.Game.Teleport(playerPed, coords)
end)