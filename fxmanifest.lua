fx_version 'cerulean'
game 'gta5'

author ''
description ''
version '0'
url ''

debug_mode 'true'

framework 'qb-core'

callback 'ox_lib'

target 'ox_target'

menu 'ox_lib'

notify 'native'

files {
  'init.lua',
  'shared/*.lua',
  'modules/**/shared.lua',
  'modules/**/**/shared.lua',
  'modules/**/**/client.lua'
}

lua54 'yes'