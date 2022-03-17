-- https://github.com/Blumlaut/TrafficAdjuster/blob/master/traffic.lua
CreateThread(function()
  for i = 1, 16 do
    EnableDispatchService(i, false)
  end
  while true do
    -- These natives has to be called every frame.
    SetVehicleDensityMultiplierThisFrame(0.0) -- No deberían aparecer conductores por ahí
    SetPedDensityMultiplierThisFrame((Config.Traffic.PedestrianAmount / 100) + .0)
    SetRandomVehicleDensityMultiplierThisFrame(0.0) -- No deberían aparecer conductores por ahí
    SetParkedVehicleDensityMultiplierThisFrame((Config.Traffic.ParkedAmount / 100) + .0)
    SetScenarioPedDensityMultiplierThisFrame((Config.Traffic.PedestrianAmount / 100) + .0,
        (Config.Traffic.PedestrianAmount / 100) + .0)
    SetRandomBoats(false)
    SetRandomTrains(false)
    SetGarbageTrucks(false)
    Wait(0)
  end
end)
