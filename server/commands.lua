RegisterCommand('getcoords', function(source, args, rawCommand)
  local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(source)))
  print("X: " .. ZRP.Math.Round(x,3) .. " Y: " .. ZRP.Math.Round(y,3) .. " Z: " .. ZRP.Math.Round(z,3))
end, false)

RegisterCommand('random', function(source, args, rawCommand)
  local val = tonumber(args[1])
  if type(val) == 'number' and val > 0 then
    local str = ZRP.GetRandomString(val)
    print(str)
  else
    print("Uso: /random <numero>")
  end
end, false)

RegisterCommand('arma', function(source, args, rawCommand)
  local arma = args[1]
  print(ZRP.GetWeaponLabel(arma))
end, false)