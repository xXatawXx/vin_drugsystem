fx_version 'adamant'
games { 'rdr3', 'gta5' }

author 'Vinny aka xXatawXx ( Thx T1ger )'
description 'Semi-Advanced Drug System'
version '1.0.5'

client_scripts {
    "config.lua",
    "client/main.lua"
}

server_scripts {
    "@async/async.lua",
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "server/main.lua"
}
