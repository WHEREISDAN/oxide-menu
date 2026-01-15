fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'oxide-menu'
description 'Modern menu system for QBCore with qb-menu data format support'
author 'Oxide Studios'
version '1.0.0'

escrow_ignore {
    '**/*',
    '*',
}

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/*.css',
}

dependencies {
    'qb-core',
}
