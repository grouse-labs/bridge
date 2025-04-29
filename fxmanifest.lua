fx_version 'cerulean'
game 'gta5'

author ''
description ''
version '0'
url ''

-- If the framework is ESX, the job_types below is used to determine the job type of the player.
-- Add the job type to the job_types if it is not already present, as well as any additional jobs that should be considered part of that job type.
job_types 'leo' {
  ['police'] = 1,
  ['fib'] = 2,
  ['sheriff'] = 3
}

job_types 'ems' {
  ['ambulance'] = 1,
  ['doctor'] = 2,
  ['ems'] = 3
}

client_script 'client/main.lua'

files {
  'init.lua',
  'shared/*.lua',
  'src/**/shared.lua',
  'src/**/**/shared.lua',
  'src/**/**/client.lua'
}

dependency 'gr_lib'

lua54 'yes'
