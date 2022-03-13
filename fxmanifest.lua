fx_version 'cerulean'
game 'gta5'

author 'Chicle <hola@chicle.dev>'
description 'ZRP Framework'
version '0.0.1'

server_scripts {
  '@async/async.lua',
	'@mysql-async/lib/MySQL.lua',

  'locale.lua',
  'locales/*.lua',

  'config.lua',
  'config.weapons.lua',

  'server/shared.lua', 
  'server/classes/player.lua',
  'server/functions.lua',
  'server/events.lua',
  'server/main.lua', 
  'server/commands.lua',

  'shared/modules/math.lua',
  'shared/modules/table.lua',
  'shared/functions.lua',
}

client_scripts {
  'locale.lua',
  'locales/*.lua',

  'config.lua',
  'config.weapons.lua',

  'client/shared.lua', 
  'client/main.lua', 

  'shared/modules/math.lua',
  'shared/modules/table.lua',
  'shared/functions.lua'
}

dependencies {
	'mysql-async',
	'async'
}