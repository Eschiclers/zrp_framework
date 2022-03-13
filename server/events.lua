RegisterNetEvent('zrp_framework:onPlayerJoined')
AddEventHandler('zrp_framework:onPlayerJoined', function()
	if not ZRP.Players[source] then
		onPlayerJoined(source)
	end
end)

function onPlayerJoined(playerId)
	local identifier

	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, 'license:') then
			identifier = string.sub(v, 9)
			break
		end
	end

	if identifier then
		if ZRP.GetPlayerFromIdentifier(identifier) then
			DropPlayer(playerId, ('there was an error loading your character!\nError code: identifier-active-ingame\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same Rockstar account.\n\nYour Rockstar identifier: %s'):format(identifier))
		else
			MySQL.Async.fetchScalar('SELECT 1 FROM users WHERE identifier = @identifier', {
				['@identifier'] = identifier
			}, function(result)
				if result then
					LoadPlayer(identifier, playerId)
				else
					MySQL.Async.execute('INSERT INTO users (identifier) VALUES (@identifier)', {
						['@identifier'] = identifier
					}, function(rowsChanged)
						LoadPlayer(identifier, playerId)
					end)
				end
			end)
		end
	else
		DropPlayer(playerId, 'there was an error loading your character!\nError code: identifier-missing-ingame\n\nThe cause of this error is not known, your identifier could not be found. Please come back later or report this problem to the server administration team.')
	end
end

function LoadPlayer(identifier, playerId)
	local tasks = {}

	local userData = {
		inventory = {},
		loadout = {},
		playerName = GetPlayerName(playerId),
		weight = 0
	}

	table.insert(tasks, function(cb)
		MySQL.Async.fetchAll('SELECT `group`, loadout, position, inventory FROM users WHERE identifier = @identifier', {
			['@identifier'] = identifier
		}, function(result)
			local foundItems = {}

			-- Inventory
			if result[1].inventory and result[1].inventory ~= '' then
				local inventory = json.decode(result[1].inventory)

				for name,count in pairs(inventory) do
					local item = ZRP.Items[name]

					if item then
						foundItems[name] = count
					else
						print(('[zrp_framework] [^3WARNING^7] Ignoring invalid item "%s" for "%s"'):format(name, identifier))
					end
				end
			end

			for name,item in pairs(ZRP.Items) do
				local count = foundItems[name] or 0
				if count > 0 then userData.weight = userData.weight + (item.weight * count) end

				table.insert(userData.inventory, {
					name = name,
					count = count,
					label = item.label,
					weight = item.weight,
					usable = ZRP.UsableItemsCallbacks[name] ~= nil,
					rare = item.rare,
					canRemove = item.canRemove
				})
			end

			table.sort(userData.inventory, function(a, b)
				return a.label < b.label
			end)

			-- Group
			if result[1].group then
				userData.group = result[1].group
			else
				userData.group = 'user'
			end

			-- Loadout
			if result[1].loadout and result[1].loadout ~= '' then
				local loadout = json.decode(result[1].loadout)

				for name,weapon in pairs(loadout) do
					local label = ZRP.GetWeaponLabel(name)

					if label then
						if not weapon.components then weapon.components = {} end
						if not weapon.tintIndex then weapon.tintIndex = 0 end

						table.insert(userData.loadout, {
							name = name,
							ammo = weapon.ammo,
							label = label,
							components = weapon.components,
							tintIndex = weapon.tintIndex
						})
					end
				end
			end

			-- Position
			if result[1].position and result[1].position ~= '' then
				userData.coords = json.decode(result[1].position)
			else
				print('[zrp_framework] [^3WARNING^7] Column "position" in "users" table is missing required default value. Using backup coords, fix your database.')
				userData.coords = {x = -269.4, y = -955.3, z = 31.2, heading = 205.8}
			end

			cb()
		end)
	end)

	Async.parallel(tasks, function(results)
		local zPlayer = CreatePlayer(playerId, identifier, userData.group, userData.inventory, userData.weight, userData.loadout, userData.playerName, userData.coords)
		ZRP.Players[playerId] = zPlayer
		TriggerEvent('zrp_framework:playerLoaded', playerId, zPlayer)

		zPlayer.triggerEvent('zrp_framework:playerLoaded', {
			coords = zPlayer.getCoords(),
			identifier = zPlayer.getIdentifier(),
			inventory = zPlayer.getInventory(),
			loadout = zPlayer.getLoadout(),
			maxWeight = zPlayer.getMaxWeight()
		})

		zPlayer.triggerEvent('zrp_framework:createMissingPickups', ZRP.Pickups)
		zPlayer.triggerEvent('zrp_framework:registerSuggestions', ZRP.RegisteredCommands)
		print(('[zrp_framework] [^2INFO^7] A player with name "%s^7" has connected to the server with assigned player id %s'):format(zPlayer.getName(), playerId))
	end)
end

-- Evitar que escriba comandos en el chat como texto
AddEventHandler('chatMessage', function(playerId, author, message)
	if message:sub(1, 1) == '/' and playerId > 0 then
		CancelEvent()
		local commandName = message:sub(1):gmatch("%w+")()
		TriggerClientEvent('chat:addMessage', playerId, {args = {_('system'), _U('commanderror_invalidcommand', commandName)}})
	end
end)

AddEventHandler('playerDropped', function(reason)
	local playerId = source
	local zPlayer = ZRP.GetPlayerFromId(playerId)

	if zPlayer then
		TriggerEvent('zrp_framework:playerDropped', playerId, reason)

		ZRP.SavePlayer(zPlayer, function()
			ZRP.Players[playerId] = nil
		end)
	end
end)

RegisterNetEvent('zrp_framework:updateCoords')
AddEventHandler('zrp_framework:updateCoords', function(coords)
	local zPlayer = ZRP.GetPlayerFromId(source)

	if zPlayer then
		zPlayer.updateCoords(coords)
	end
end)

RegisterNetEvent('zrp_framework:updateWeaponAmmo')
AddEventHandler('zrp_framework:updateWeaponAmmo', function(weaponName, ammoCount)
	local zPlayer = ZRP.GetPlayerFromId(source)

	if zPlayer then
		zPlayer.updateWeaponAmmo(weaponName, ammoCount)
	end
end)

RegisterNetEvent('zrp_framework:giveInventoryItem')
AddEventHandler('zrp_framework:giveInventoryItem', function(target, type, itemName, itemCount)
	local playerId = source
	local sourceZPlayer = ZRP.GetPlayerFromId(playerId)
	local targetZPlayer = ZRP.GetPlayerFromId(target)

	if type == 'item_standard' then
		local sourceItem = sourcePlayer.getInventoryItem(itemName)

		if itemCount > 0 and sourceItem.count >= itemCount then
			if targetZPlayer.canCarryItem(itemName, itemCount) then
				sourceZPlayer.removeInventoryItem(itemName, itemCount)
				targetZPlayer.addInventoryItem(itemName, itemCount)

				sourceZPlayer.showNotification(_U('gave_item', itemCount, sourceItem.label, targetZPlayer.name))
				targetZPlayer.showNotification(_U('received_item', itemCount, sourceItem.label, sourceZPlayer.name))
			else
				sourceZPlayer.showNotification(_U('ex_inv_lim', targetZPlayer.name))
			end
		else
			sourceZPlayer.showNotification(_U('imp_invalid_quantity'))
		end
	elseif type == 'item_weapon' then
		if sourceZPlayer.hasWeapon(itemName) then
			local weaponLabel = ZRP.GetWeaponLabel(itemName)

			if not targetZPlayer.hasWeapon(itemName) then
				local _, weapon = sourceZPlayer.getWeapon(itemName)
				local _, weaponObject = ZRP.GetWeapon(itemName)
				itemCount = weapon.ammo

				sourceZPlayer.removeWeapon(itemName)
				targetZPlayer.addWeapon(itemName, itemCount)

				if weaponObject.ammo and itemCount > 0 then
					local ammoLabel = weaponObject.ammo.label
					sourceZPlayer.showNotification(_U('gave_weapon_withammo', weaponLabel, itemCount, ammoLabel, targetZPlayer.name))
					targetZPlayer.showNotification(_U('received_weapon_withammo', weaponLabel, itemCount, ammoLabel, sourceZPlayer.name))
				else
					sourceZPlayer.showNotification(_U('gave_weapon', weaponLabel, targetZPlayer.name))
					targetZPlayer.showNotification(_U('received_weapon', weaponLabel, sourceZPlayer.name))
				end
			else
				sourceZPlayer.showNotification(_U('gave_weapon_hasalready', targetZPlayer.name, weaponLabel))
				targetZPlayer.showNotification(_U('received_weapon_hasalready', sourceZPlayer.name, weaponLabel))
			end
		end
	elseif type == 'item_ammo' then
		if sourceZPlayer.hasWeapon(itemName) then
			local weaponNum, weapon = sourceZPlayer.getWeapon(itemName)

			if targetZPlayer.hasWeapon(itemName) then
				local _, weaponObject = ZRP.GetWeapon(itemName)

				if weaponObject.ammo then
					local ammoLabel = weaponObject.ammo.label

					if weapon.ammo >= itemCount then
						sourceZPlayer.removeWeaponAmmo(itemName, itemCount)
						targetZPlayer.addWeaponAmmo(itemName, itemCount)

						sourceZPlayer.showNotification(_U('gave_weapon_ammo', itemCount, ammoLabel, weapon.label, targetZPlayer.name))
						targetZPlayer.showNotification(_U('received_weapon_ammo', itemCount, ammoLabel, weapon.label, sourceZPlayer.name))
					end
				end
			else
				sourceZPlayer.showNotification(_U('gave_weapon_noweapon', targetZPlayer.name))
				targetZPlayer.showNotification(_U('received_weapon_noweapon', sourceZPlayer.name, weapon.label))
			end
		end
	end
end)

RegisterNetEvent('zrp_framework:removeInventoryItem')
AddEventHandler('zrp_framework:removeInventoryItem', function(type, itemName, itemCount)
	local playerId = source
	local zPlayer = ZRP.GetPlayerFromId(source)

	if type == 'item_standard' then
		if itemCount == nil or itemCount < 1 then
			zPlayer.showNotification(_U('imp_invalid_quantity'))
		else
			local zItem = zPlayer.getInventoryItem(itemName)

			if (itemCount > zItem.count or zItem.count < 1) then
				zPlayer.showNotification(_U('imp_invalid_quantity'))
			else
				zPlayer.removeInventoryItem(itemName, itemCount)
				local pickupLabel = ('~y~%s~s~ [~b~%s~s~]'):format(zItem.label, itemCount)
				ZRP.CreatePickup('item_standard', itemName, itemCount, pickupLabel, playerId)
				zPlayer.showNotification(_U('threw_standard', itemCount, zItem.label))
			end
		end
	elseif type == 'item_weapon' then
		itemName = string.upper(itemName)

		if zPlayer.hasWeapon(itemName) then
			local _, weapon = zPlayer.getWeapon(itemName)
			local _, weaponObject = ZRP.GetWeapon(itemName)
			local components, pickupLabel = ZRP.Table.Clone(weapon.components)
			zPlayer.removeWeapon(itemName)

			if weaponObject.ammo and weapon.ammo > 0 then
				local ammoLabel = weaponObject.ammo.label
				pickupLabel = ('~y~%s~s~ [~g~%s~s~ %s]'):format(weapon.label, weapon.ammo, ammoLabel)
				zPlayer.showNotification(_U('threw_weapon_ammo', weapon.label, weapon.ammo, ammoLabel))
			else
				pickupLabel = ('~y~%s~s~'):format(weapon.label)
				zPlayer.showNotification(_U('threw_weapon', weapon.label))
			end

			ZRP.CreatePickup('item_weapon', itemName, weapon.ammo, pickupLabel, playerId, components, weapon.tintIndex)
		end
	end
end)

RegisterNetEvent('zrp_framework:useItem')
AddEventHandler('zrp_framework:useItem', function(itemName)
	local zPlayer = ZRP.GetPlayerFromId(source)
	local count = zPlayer.getInventoryItem(itemName).count

	if count > 0 then
		ZRP.UseItem(source, itemName)
	else
		zPlayer.showNotification(_U('act_imp'))
	end
end)

RegisterNetEvent('zrp_framework:onPickup')
AddEventHandler('zrp_framework:onPickup', function(pickupId)
	local pickup, zPlayer, success = ZRP.Pickups[pickupId], ZRP.GetPlayerFromId(source)

	if pickup then
		if pickup.type == 'item_standard' then
			if zPlayer.canCarryItem(pickup.name, pickup.count) then
				zPlayer.addInventoryItem(pickup.name, pickup.count)
				success = true
			else
				zPlayer.showNotification(_U('threw_cannot_pickup'))
			end
		elseif pickup.type == 'item_weapon' then
			if zPlayer.hasWeapon(pickup.name) then
				zPlayer.showNotification(_U('threw_weapon_already'))
			else
				success = true
				zPlayer.addWeapon(pickup.name, pickup.count)
				zPlayer.setWeaponTint(pickup.name, pickup.tintIndex)

				for k,v in ipairs(pickup.components) do
					zPlayer.addWeaponComponent(pickup.name, v)
				end
			end
		end

		if success then
			ZRP.Pickups[pickupId] = nil
			TriggerClientEvent('zrp_framework:removePickup', -1, pickupId)
		end
	end
end)

ZRP.RegisterServerCallback('zrp_framework:getPlayerData', function(source, cb)
	local zPlayer = ZRP.GetPlayerFromId(source)

	cb({
		identifier   = zPlayer.identifier,
		inventory    = zPlayer.getInventory(),
		loadout      = zPlayer.getLoadout()
	})
end)

ZRP.RegisterServerCallback('zrp_framework:getOtherPlayerData', function(source, cb, target)
	local zPlayer = ZRP.GetPlayerFromId(target)

	cb({
		identifier   = zPlayer.identifier,
		inventory    = zPlayer.getInventory(),
		loadout      = zPlayer.getLoadout()
	})
end)

ZRP.RegisterServerCallback('zrp_framework:getPlayerNames', function(source, cb, players)
	players[source] = nil

	for playerId,v in pairs(players) do
		local zPlayer = ZRP.GetPlayerFromId(playerId)

		if zPlayer then
			players[playerId] = zPlayer.getName()
		else
			players[playerId] = nil
		end
	end

	cb(players)
end)