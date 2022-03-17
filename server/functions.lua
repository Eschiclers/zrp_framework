ZRP.SetTimeout = function(msec, cb)
  local id = ZRP.TimeoutCount + 1

  SetTimeout(msec, function()
    if ZRP.CancelledTimeouts[id] then
      ZRP.CancelledTimeouts[id] = nil
    else
      cb()
    end
  end)

  ESX.TimeoutCount = id

  return id
end

ZRP.ClearTimeout = function(id)
  ZRP.CancelledTimeouts[id] = true
end

ZRP.RegisterCommand = function(name, group, cb, allowConsole, suggestion)
  if type(name) == 'table' then
    for k, v in ipairs(name) do
      ZRP.RegisterCommand(v, group, cb, allowConsole, suggestion)
    end

    return
  end

  if ZRP.RegisteredCommands[name] then
    print(('[zrp_framework] [^3WARNING^7] An command "%s" is already registered, overriding command'):format(name))

    if ZRP.RegisteredCommands[name].suggestion then
      TriggerClientEvent('chat:removeSuggestion', -1, ('/%s'):format(name))
    end
  end

  if suggestion then
    if not suggestion.arguments then
      suggestion.arguments = {}
    end
    if not suggestion.help then
      suggestion.help = ''
    end

    TriggerClientEvent('chat:addSuggestion', -1, ('/%s'):format(name), suggestion.help, suggestion.arguments)
  end

  ZRP.RegisteredCommands[name] = {
    group = group,
    cb = cb,
    allowConsole = allowConsole,
    suggestion = suggestion
  }

  RegisterCommand(name, function(playerId, args, rawCommand)
    local command = ZRP.RegisteredCommands[name]

    if not command.allowConsole and playerId == 0 then
      print(('[zrp_framework] [^3WARNING^7] %s'):format(_U('commanderror_console')))
    else
      local zPlayer, error = ZRP.GetPlayerFromId(playerId), nil

      if command.suggestion then
        if command.suggestion.validate then
          if #args ~= #command.suggestion.arguments then
            error = _U('commanderror_argumentmismatch', #args, #command.suggestion.arguments)
          end
        end

        if not error and command.suggestion.arguments then
          local newArgs = {}

          for k, v in ipairs(command.suggestion.arguments) do
            if v.type then
              if v.type == 'number' then
                local newArg = tonumber(args[k])

                if newArg then
                  newArgs[v.name] = newArg
                else
                  error = _U('commanderror_argumentmismatch_number', k)
                end
              elseif v.type == 'player' or v.type == 'playerId' then
                local targetPlayer = tonumber(args[k])

                if args[k] == 'me' then
                  targetPlayer = playerId
                end

                if targetPlayer then
                  local xTargetPlayer = ZRP.GetPlayerFromId(targetPlayer)

                  if xTargetPlayer then
                    if v.type == 'player' then
                      newArgs[v.name] = xTargetPlayer
                    else
                      newArgs[v.name] = targetPlayer
                    end
                  else
                    error = _U('commanderror_invalidplayerid')
                  end
                else
                  error = _U('commanderror_argumentmismatch_number', k)
                end
              elseif v.type == 'string' then
                newArgs[v.name] = args[k]
              elseif v.type == 'item' then
                if ZRP.Items[args[k]] then
                  newArgs[v.name] = args[k]
                else
                  error = _U('commanderror_invaliditem')
                end
              elseif v.type == 'weapon' then
                if ZRP.GetWeapon(args[k]) then
                  newArgs[v.name] = string.upper(args[k])
                else
                  error = _U('commanderror_invalidweapon')
                end
              elseif v.type == 'any' then
                newArgs[v.name] = args[k]
              end
            end

            if error then
              break
            end
          end

          args = newArgs
        end
      end

      if error then
        if playerId == 0 then
          print(('[zrp_framework] [^3WARNING^7] %s^7'):format(error))
        else
          zPlayer.triggerEvent('chat:addMessage', {
            args = {'^1SYSTEM', error}
          })
        end
      else
        cb(zPlayer or false, args, function(msg)
          if playerId == 0 then
            print(('[zrp_framework] [^3WARNING^7] %s^7'):format(msg))
          else
            zPlayer.triggerEvent('chat:addMessage', {
              args = {'^1SYSTEM', msg}
            })
          end
        end)
      end
    end
  end, true)

  if type(group) == 'table' then
    for k, v in ipairs(group) do
      ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name))
    end
  else
    ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
  end
end

ZRP.StartDBSync = function()
  function saveData()
    ZRP.SavePlayers()
    SetTimeout(10 * 60 * 1000, saveData)
  end

  SetTimeout(10 * 60 * 1000, saveData)
end

ZRP.GetPlayers = function()
  local sources = {}

  for k, v in pairs(ZRP.Players) do
    table.insert(sources, k)
  end

  return sources
end

ZRP.GetPlayerFromId = function(id)
  return ZRP.Players[id]
end

ZRP.GetPlayerFromIdentifier = function(identifier)
  for k, v in pairs(ZRP.Players) do
    if v.identifier == identifier then
      return v
    end
  end

  return false
end

ZRP.RegisterUsableItem = function(item, callback)
  ZRP.UsableItemsCallback[item] = callback
end

ZRP.UseItem = function(source, item)
  ZRP.UsableItemsCallback[item](source, item)
end

ZRP.GetItemlabel = function(item)
  if ZRP.Items[item] then
    return ZRP.Items[item].label
  end
end

ZRP.CreatePickup = function(type, name, count, label, playerId, components, tintIndex)
  local pickupId = (ZRP.PickupId == 65635 and 0 or ZRP.PickupId + 1)
  local zPlayer = ZRP.GetPlayerFromId(playerId)
  local coords = zPlayer.getCoords()

  ZRP.Pickups[pickupId] = {
    type = type,
    name = name,
    count = count,
    label = label,
    coords = coords
  }

  if type == 'item_weapon' then
    ZRP.Pickups[pickupId].components = components
    ZRP.Pickups[pickupId].tintIndex = tintIndex
  end

  TriggerClientEvent('zrp_framework:createPickup', -1, pickupId, label, coords, type, name, components, tintIndex)
  ZRP.PickupId = pickupId
end

ZRP.RegisterServerCallback = function(name, cb)
  ZRP.ServerCallbacks[name] = cb
end

ZRP.TriggerServerCallback = function(name, requestId, source, cb, ...)
  if ZRP.ServerCallbacks[name] then
    ZRP.ServerCallbacks[name](source, cb, ...)
  else
    print(
        ('[zrp_framework] [^3WARNING^7] Server callback "%s" does not exist. Make sure that the server sided file really is loading, an error in that file might cause it to not load.'):format(
            name))
  end
end

ZRP.SavePlayer = function(zPlayer, cb)
  local asyncTasks = {}

  table.insert(asyncTasks, function(cb2)
    MySQL.Async.execute(
        'UPDATE users SET `group` = @group, loadout = @loadout, position = @position, inventory = @inventory WHERE identifier = @identifier',
        {
          ['@group'] = zPlayer.getGroup(),
          ['@loadout'] = json.encode(zPlayer.getLoadout(true)),
          ['@position'] = json.encode(zPlayer.getCoords()),
          ['@identifier'] = zPlayer.getIdentifier(),
          ['@inventory'] = json.encode(zPlayer.getInventory(true))
        }, function(rowsChanged)
          cb2()
        end)
  end)

  Async.parallel(asyncTasks, function(results)
    print(('[zrp_framework] [^2INFO^7] Saved player "%s^7"'):format(zPlayer.getName()))

    if cb then
      cb()
    end
  end)
end

ZRP.SavePlayers = function(cb)
  local zPlayers, asyncTasks = ZRP.GetPlayers(), {}

  for i = 1, #zPlayers, 1 do
    table.insert(asyncTasks, function(cb2)
      local zPlayer = ZRP.GetPlayerFromId(zPlayers[i])
      ZRP.SavePlayer(zPlayer, cb2)
    end)
  end

  Async.parallelLimit(asyncTasks, 8, function(results)
    print(('[zrp_framework] [^2INFO^7] Saved %s player(s)'):format(#zPlayers))
    if cb then
      cb()
    end
  end)
end

ZRP.GetItemsFromDb = function(cb)
  MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
    for k, v in ipairs(result) do
      ZRP.Items[v.name] = {
        label = v.label,
        weight = v.weight,
        rare = v.rare,
        canRemove = v.can_remove
      }
    end
    cb(result)
  end)
end

ZRP.CheckVersion = function()
  if not Config.CheckVersion then return end

  PerformHttpRequest(('https://api.github.com/repos/%s/releases'):format(GetResourceMetadata(GetCurrentResourceName(), 'repository', 0)), function(code, data, headers)
    if code ~= 200 then
      print(('[^5ZRP Framework^7] [^1ERROR^7] No se pudo comprobar la versión'))
      return
    end

    local json = json.decode(data)

    local last_version = json[1].tag_name
    local version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)

    if last_version > version then
      print("[^5ZRP Framework] ^3Hay una nueva versión disponible: ^7" .. last_version)
      print(("[^5ZRP Framework] ^3Descarga la nueva versión desde: ^7https://github.com/%s/releases"):format(GetResourceMetadata(GetCurrentResourceName(), 'repository', 0)))
    end
  end)

  -- Espera 8 horas y vuelve a comprobar la versión
  SetTimeout(8 * 60 * 60 * 1000, ZRP.CheckVersion)

end