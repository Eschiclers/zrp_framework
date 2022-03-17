ZRP.RegisterCommand('setcoords', {'admin'}, function(zPlayer, args, showError)
    zPlayer.setCoords({
        x = args.x,
        y = args.y,
        z = args.z
    })
end, false, {
    help = _U('command_setcoords'),
    validate = true,
    arguments = {{
        name = 'x',
        help = _U('command_setcoords_x'),
        type = 'number'
    }, {
        name = 'y',
        help = _U('command_setcoords_y'),
        type = 'number'
    }, {
        name = 'z',
        help = _U('command_setcoords_z'),
        type = 'number'
    }}
})

ZRP.RegisterCommand('save', {'admin'}, function(zPlayer, args, showError)
    ZRP.SavePlayer(args.playerId)
end, true, {
    help = _U('command_save'),
    validate = true,
    arguments = {{
        name = 'playerId',
        help = _U('commandgeneric_playerid'),
        type = 'player'
    }}
})

ZRP.RegisterCommand('saveall', {'admin'}, function(zPlayer, args, showError)
    ZRP.SavePlayers()
end, true, {
    help = _U('command_saveall')
})

ZRP.RegisterCommand('setgroup', {'admin'}, function(zPlayer, args, showError)
    args.playerId.setGroup(args.group)
end, true, {
    help = _U('command_setgroup'),
    validate = true,
    arguments = {{
        name = 'playerId',
        help = _U('commandgeneric_playerid'),
        type = 'player'
    }, {
        name = 'group',
        help = _U('command_setgroup_group'),
        type = 'string'
    }}
})

ZRP.RegisterCommand({'veh', 'vehicle', 'car'}, {'admin'}, function(zPlayer, args, showError)
    zPlayer.triggerEvent('zrp_framework:spawnVehicle', args.car)
    print(args.car)
end, false, {
    help = _U('command_car'),
    validate = false,
    arguments = {{
        name = 'car',
        help = _U('command_car_car'),
        type = 'any'
    }}
})

ZRP.RegisterCommand({'cardel', 'dv'}, {'admin'}, function(zPlayer, args, showError)
    zPlayer.triggerEvent('zrp_framework:deleteVehicle', args.radius)
end, false, {
    help = _U('command_cardel'),
    validate = false,
    arguments = {{
        name = 'radius',
        help = _U('command_cardel_radius'),
        type = 'any'
    }}
})
