SetMapName(Config.MapName)
SetGameType(Config.GameType)

-- Aquí ejecutaremos lo necesario cuando MySQL esté listo
MySQL.ready(function()
  ZRP.GetItemsFromDb(function(result)
    print(('[zrp_framework] [^2INFO^7] %s Items loaded'):format(#result))
  end)
end)

ZRP.StartDBSync()
