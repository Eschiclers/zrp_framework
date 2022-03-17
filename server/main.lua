SetMapName(Config.MapName)
SetGameType(Config.GameType)

-- Aquí ejecutaremos lo necesario cuando MySQL esté listo
MySQL.ready(function()
  ZRP.GetItemsFromDb(function(result)
    print(('[^5ZRP Framework^7] [^2INFO^7] %s Items loaded'):format(#result))
  end)
end)

ZRP.StartDBSync()

-- Comprobamos la versión del script y si hay alguna nueva
ZRP.CheckVersion()