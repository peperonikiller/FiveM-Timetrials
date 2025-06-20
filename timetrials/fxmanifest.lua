fx_version 'adamant'

game 'gta5'

description '[QB]TimeTrials Remastered'

version '0.7.0'


client_scripts {
	"tracks.lua",
	"timetrials_cl.lua"
}

server_scripts {
	"timetrials_sv.lua"
}

shared_scripts {
    'config.lua'
} 

dependencies {
    'cw-performance'
}

files {
    'scores.txt'
}