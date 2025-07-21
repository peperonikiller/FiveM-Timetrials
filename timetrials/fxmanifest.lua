fx_version 'cerulean'

game 'gta5'

description '[QB]TimeTrials Remastered'
author 'Brent_Peterson | Remaster: Peperonikiller'

version '0.8.5'


client_scripts {
	'tracks.lua',
	'timetrials_cl.lua',
    'framework/client/*.lua',
    'vehicle_names.lua',
}

server_scripts {
	'timetrials_sv.lua'
}

shared_scripts {
    'shared/config.lua'
}

dependencies {
    'cw-performance'
}

files {
    'scores.json'
}
