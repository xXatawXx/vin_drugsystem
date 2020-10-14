fx_version 'adamant'
games { 'rdr3', 'gta5' }

author 'Vinny aka xXatawXx'
description 'Semi-Advanced Drug System using hashtables {}.'
version '1.0.5'

client_scripts {
    "config.lua",
    "client/main.lua"
}

server_scripts {
	'@async/async.lua',
	"@mysql-async/lib/MySQL.lua",
    "config.lua",
    "server/main.lua"
}
