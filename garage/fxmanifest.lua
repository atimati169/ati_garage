fx_version 'adamant'

game 'gta5'

client_scripts {
	"@NativeUI/NativeUI.lua",
	"config.lua",
	"client.lua"
}

server_scripts {
	"config.lua",
	"server.lua",
	"@mysql-async/lib/MySQL.lua"
}

shared_script '@es_extended/imports.lua'