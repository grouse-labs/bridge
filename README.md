# bridge

A modular bridge framework for FiveM that simplifies cross-resource integration and reduces framework coupling.

## Features

- **core** | Exposes most framework specfic functions for `'qb-core'`, `'es_extended'` & `'qbx_core'`.
- **callback** | Exposes all callback functions for `'ox_lib'` & `'gr_lib'`.
- **menu** | Exposes (similar) menu functions for `'ox_lib'` & `'qb-menu'`.
- **notify** | Exposes all notify functions for `'qb-core'` (includes `'qbx_core'`), `'es_extended'` & has a `'native'` fallback.
- **target** | Exposes some target functions for `'ox_target'` & `'qb-target'`.

## Table of Contents

- [bridge](#bridge)
  - [Features](#features)
  - [Table of Contents](#table-of-contents)
    - [Supported Resources](#supported-resources)
    - [Installation](#installation)
    - [Configuration](#configuration)
      - [Annotations](#annotations)
        - [Usage (VS Code)](#usage-vs-code)
      - [Server CFG](#server-cfg)
    - [Documentation](#documentation)
      - [core](#core)
      - [callback](#callback)
      - [menu](#menu)
      - [notify](#notify)
      - [target](#target)
      - [doorlock](#doorlock)
      - [weather](#weather)
    - [Support](#support)

### Supported Resources

| Framework   | Callback | Target    | Menu    | Notify      | Doorlock    | Weather             |
| ----------- | -------- | --------- | ------- | ----------- | ----------- | ------------------- |
| qb-core     | ox_lib   | ox_target | ox_lib  | qb-core     | ox_doorlock | Renewed-Weathersync |
| es_extended | gr_lib   | qb-target | qb-menu | es_extended | qb-doorlock | qb-weathersync      |
| qbx_core    |          |           |         |             |             |                     |

| Resource            | Version |
| :------------------ | :-----: |
| qb-core             | 1.3.0   |
| es_extended         | 1.13.4  |
| qbx_core            | 1.23.0  |
| ox_lib              | 3.30.6  |
| gr_lib              | 1.0.0   |
| ox_target           | 1.17.2  |
| qb-target           | 5.5.0   |
| qb-menu             | 1.2.0   |
| ox_doorlock         | 1.17.2  |
| qb-doorlock         | 2.0.0   |
| Renewed-Weathersync | 1.1.8   |
| qb-weathersync      | 2.1.1   |

### Installation

- Always use the reccomended FiveM artifacts, last tested on [23683](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/).
- Download the latest version from [releases](https://github.com/grouse-labs/gr_bridge/releases/latest).
- Extract the contents of the zip file into your resources folder, into a folder which starts after [gr_lib](https://github.com/grouse-labs/gr_lib/);
- Ensure the script in your `server.cfg` after [gr_lib](https://github.com/grouse-labs/gr_lib/) and before any script this is a dependency for.

### Configuration

#### Annotations

Function completion is available for all functions, enums and classes. This means you can see what parameters a function takes, what an enum value is, or what a class field is. This is done through [Lua Language Server](https://github.com/LuaLS/lua-language-server).

##### Usage (VS Code)

- Install [cfxlua-vscode](https://marketplace.visualstudio.com/items?itemName=overextended.cfxlua-vscode).
- Open your settings (Ctrl + ,) and add the following:
  - Search for `Lua.workspace.library`, and create a new entry pointing to the root of the resource, for example:

```json
"Lua.workspace.library": ["F:/resources/[gr]/bridge/"],
```

#### Server CFG

The following is how to manually change bridge resources and set debug mode.
**Note: Most users will not need this as bridge autodetects your framework and other resources.**

```cfg
##############
### BRIDGE ###
##############

setr grinch:framework "qbx_core" # Set the framework to use for bridge. Options are "qb-core", "qbx_core" or "es_extended".
setr grinch:callback "gr_lib" # Set the callback to use for bridge. Currently the only options are "ox_lib" or "gr_lib".
setr grinch:target "ox_target" # Set the target to use for bridge. Options are "qb-target" or "ox_target".
setr grinch:menu "ox_lib" # Set the menu to use for bridge. Options are "qb-menu" or "ox_lib".
setr grinch:notify "qb-core" # Set the notification to use for bridge. Options are "qb-core", "es_extended" or "native".
setr grinch:doorlock "ox_doorlock" # Set the doorlock to use for bridge. Options are "ox_doorlock" or "qb-doorlock".
setr grinch:weather "Renewed-Weathersync" # Set the weather to use for bridge. Options are "Renewed-Weathersync" or "qb-weathersync".
```

| Framework   | Callback | Target    | Menu    | Notify      | Doorlock    | Weather             |
| ----------- | -------- | --------- | ------- | ----------- | ----------- | ------------------- |
| qb-core     | ox_lib   | ox_target | ox_lib  | qb-core     | ox_doorlock | Renewed-Weathersync |
| es_extended | gr_lib   | qb-target | qb-menu | es_extended | qb-doorlock | qb-weathersync      |
| qbx_core    |          |           |         |             |             |                     |

### Documentation

#### core

```lua
---@return 'qb-core'|'es_extended'|'qbx_core'
-- Returns the framework name.
function core.getname()

---@return string version
-- Returns the framework version as defined in the resource manifest.
function core.getversion()

---@return table
-- Returns the framework object.
function core.getobject()

--------------------- SERVER ---------------------

---@param player integer|string The `player` server ID or src.
---@return table Player The player object.
function core.getplayer(player)

---@param player integer|string The `player` server ID or src.
---@return string identifier The identifier of the `player`.
function core.getplayeridentifier(player)

---@param player integer|string The `player` server ID or src.
---@return string name The name of the `player`.
function core.getplayername(player)

---@param player integer|string The `player` server ID or src.
---@return {name: string, label: string, grade: number, grade_name: string, grade_label: string, job_type: string, salary: number} job_data The job data for the `player`.
function core.getplayerjob(player)

---@param player integer|string The `player` server ID or src.
---@param groups string|string[] The group(s) to check for. <br> If `groups` is a string, it is the name of the group to check for. <br> If `groups` is a table, it is a list of group names to check for. <br> The group name can be the job name, job label, job type, gang name or gang label.
---@return boolean has_group Whether the `player` has the specified group(s).
function core.doesplayerhavegroup(player, groups)

---@param player integer|string The `player` server ID or src.
---@param money_type 'money'|'cash'|'bank' The type of money to check for. <br> If `money_type` is 'cash', the player's cash is checked. <br> If `money_type` is 'bank', the player's bank is checked.
---@return integer money The amount of money the `player` has.
function core.getplayermoney(player, money_type)

---@param player integer|string The `player` server ID or src.
---@param money_type 'money'|'cash'|'bank' The type of money to add. <br> If `money_type` is 'cash', the player's has cash added. <br> If `money_type` is 'bank', the player's bank has money added to it.
---@param amount number The amount of money to add.
---@return boolean added Whether the money was added to the `player`.
function core.addplayermoney(player, money_type, amount)

---@param player integer|string The `player` server ID or src.
---@param money_type 'money'|'cash'|'bank' The type of money to remove. <br> If `money_type` is 'cash', the player's cash is removed. <br> If `money_type` is 'bank', the player's bank has money removed from it.
---@param amount number The amount of money to remove.
---@return boolean removed Whether the money was removed from the `player`.
function core.removeplayermoney(player, money_type, amount)

---@param player integer|string The `player` server ID or src.
---@return boolean is_downed Whether the `player` is downed.
function core.isplayerdowned(player)

---@param player integer|string The `player` server ID or src.
---@return {[string]: {name: string, label: string, weight: number, useable: boolean, unique: boolean, amount: integer?}} inventory The inventory for the `player`.
function core.getplayerinventory(player)

---@param player integer|string The `player` server ID or src.
---@param item_name string The `item_name` to check for.
---@param amount number? The amount of the item to check for. <br> If `amount` is nil, the default amount is 1.
---@return boolean has_item Whether the `player` has the specified `item`.
function core.doesplayerhaveitem(player, item_name, amount)

---@param player integer|string The `player` server ID or src.
---@param item_name string The `item_name` to add.
---@param amount number? The amount of the item to add. <br> If `amount` is nil, the default amount is 1.
---@return boolean added Whether the item was added to the `player`.
function core.addplayeritem(player, item_name, amount)

---@param player integer|string The `player` server ID or src.
---@param item_name string The `item_name` to remove.
---@param amount number? The amount of the item to remove. <br> If `amount` is nil, the default amount is 1.
---@return boolean removed Whether the item was removed from the `player`.
function core.removeplayeritem(player, item_name, amount)

---@param item_name string The `item_name` to check for.
---@return boolean? is_useable Whether the `item_name` is useable.
local function is_item_useable(item_name)

---@return {[string]: {name: string, label: string, weight: number, useable: boolean, unique: boolean}} Items A table of all items available in the inventory system.
function core.getitems()

---@param item_name string The name of the item to get the data for.
---@return {name: string, label: string, weight: number, useable: boolean, unique: boolean} item_data The data for the specified item.
function core.getitem(item_name)

---@param item_name string The `item_name` to create a useable item callback for.
---@param cb fun(src: number|string) The function to call when the item is used.
function core.createusableitem(item_name, cb)

---@return {[string]: {name: string, label: string, _type: string, grades: {[number]: {label: string, salary: number}}}}
function core.getjobs()

---@return {name: string, label: string, _type: string, grades: {[number]: {label: string, salary: number}}}
function core.getjob(job_name)

--------------------- CLIENT ---------------------

---@param event_type 'load'|'unload'|'job'|'player'
---@return core_events
function core.getevent(event_type)

---@return table PlayerData The player data of the `player`.
function core.getplayerdata()

---@return string identifier The identifier of the `player`.
function core.getplayeridentifier()

---@return string name The name of the `player`.
function core.getplayername()

---@return {name: string, label: string, grade: number, grade_name: string, grade_label: string, job_type: string, salary: number} job_data The job data of the `player`.
function core.getplayerjob()

---@param groups string|string[] The group(s) to check for. <br> If `groups` is a string, it is the name of the group to check for. <br> If `groups` is a table, it is a list of group names to check for. <br> The group name can be the job name, job label, job type, gang name or gang label.
---@return boolean has_group Whether the `player` has the specified group(s).
function core.doesplayerhavegroup(groups)

---@param money_type 'money'|'cash'|'bank' The type of money to check for. <br> If `money_type` is 'cash', the player's cash is checked. <br> If `money_type` is 'bank', the player's bank is checked.
---@return integer money The amount of money the `player` has.
function core.getplayermoney(money_type)
```

#### callback

```lua
---@return 'ox_lib'|'gr_lib'
-- Returns the callback resource name.
function callback.getname()

---@return string version
-- Returns the callback version as defined in the resource manifest.
function callback.getversion()

---@param name string The callback `name`.
---@param cb function The callback function.
-- Registers an event handler with a callback to the respective enviroment
function callback.register(name, cb)

--------------------- SERVER ---------------------

---@param player integer|string The `player` to trigger the callback for.
---@param name string The callback `name`.
---@param cb function The receiving callback function.
---@param ... any Additional arguments to pass to the callback.
-- Triggers a callback with the given name and calls back the data through the given function.
function callback.trigger(player, name, cb, ...)

---@param player integer|string The `player` to trigger the callback for.
---@param name string The callback `name`.
---@param ... any Additional arguments to pass to the callback.
---@return ...
function callback.await(player, name, ...)

--------------------- CLIENT ---------------------

---@param name string The callback `name`.
---@param delay integer? The delay in milliseconds before the callback is triggered.
---@param cb function The receiving callback function.
---@param ... any Additional arguments to pass to the callback.
-- Triggers a callback with the given name and calls back the data through the given function.
function callback.trigger(name, delay, cb, ...)

---@param name string The callback `name`.
---@param delay integer? The delay in milliseconds before the callback is triggered.
---@param ... any Additional arguments to pass to the callback.
---@return ...
function callback.await(name, delay, ...)
```

#### menu

This module is client only.

```lua
---@return 'ox_lib'|'qb-menu'
function menu.getname()

---@return string version
function menu.getname()

---@param menu_id string The ID of the menu to register.
---@param title string The title of the menu.
---@param options {header: string, description: string, icon: string, istitle: boolean?, disabled: boolean?, hasSubMenu: boolean?, onSelect: fun()?, event_type: string?, event: string?, args: table?}[] The options for the menu.
function menu.registermenu(menu_id, title, options)

---@param menu_id string The ID of the menu to update.
function menu.openmenu(menu_id)

function menu.closemenu()
```

#### notify

```lua
---@return 'qb-core'|'es_extended'|'native'
-- Returns the notify resource name.
function notify.getname()

---@return string version
-- Returns the notify resource version as defined in the resource manifest.
function notify.getversion()

--------------------- SERVER ---------------------

---@param player string|integer  The `player` server ID or src.
---@param text string The notify `text` as a string.
---@param _type 'error'|'success'|'primary'? The notify type. <br> Defaults to `'primary'`.
---@param time integer? The notify `time` in milliseconds.
function notify.text(player, text, _type, time)

---@param player string|integer  The `player` server ID or src.
---@param item string The item name as a string.
---@param amount integer? The item `amount` as a number. <br> Defaults to `1`.
---@param text string? The notify `text` as a string.
function notify.item(player, item, amount, text)

--------------------- CLIENT ---------------------

---@param text string The notify `text` as a string.
---@param _type 'error'|'success'|'primary'? The notify type. <br> Defaults to `'primary'`.
---@param time integer? The notify `time` in milliseconds.
function notify.text(text, _type, time)

---@param item string The item name as a string.
---@param amount integer? The item `amount` as a number. <br> Defaults to `1`.
---@param text string? The notify `text` as a string.
function notify.item(item, amount, text)
```

#### target

This module is client only.

```lua
---@return 'ox_target'|'qb-target'
function target.getname()

---@return string version
function target.getversion()

---@return table
function target.getobject()

---@param entities integer|integer[] The entity or entities to add a target to.
---@param options target_options[] The options for the target.
function target.addlocalentity(entities, options)

---@param entities integer|integer[] The entity or entities to remove a target from.
---@param options string|string[] The target or targets to remove from the entity.
function target.removelocalentity(entities, options)

---@param data {center: vector3, radius: number?, debug: boolean?} The data for the sphere zone.
---@param options target_options[] The options for the target.
---@return integer|string? box_zone The ID of the sphere zone. <br> If using ox_target, the integer ID of the zone is returned. <br> If using qb-target, the string name of the zone is returned.
function target.addspherezone(data, options)

---@param data {center: vector3, size: vector3, heading: number?, debug: boolean?} The data for the box zone.
---@param options target_options[] The options for the target.
---@return integer|string? box_zone The ID of the box zone. <br> If using ox_target, the integer ID of the zone is returned. <br> If using qb-target, the string name of the zone is returned.
function target.addboxzone(data, options)

---@param box_zone integer|string The ID of the box zone to remove.
function target.removezone(box_zone)
```

#### doorlock

This module is server only.

```lua
---@return 'ox_doorlock'|'qb-doorlock'
function doorlock.getname()

---@return string version
function doorlock.getversion()

---@param player integer|string The `player` who is changing the door state.
---@param door_id string The `door_id` to change the state of.
---@param state boolean Locks `door_id` if state is true.
---@param picked boolean? Whether the door was lockpicked by a player.
function doorlock.setstate(player, door_id, state, picked)
```

#### weather

This module is server only.

```lua
---@return 'Renewed-Weathersync'|'qb-weathersync'
function weather.getname()

---@return string version
function weather.getversion()

---@return integer hour, integer minute
function weather.gettime()
```

### Support

- Join the [Grouse Labs 🐀 discord](https://discord.gg/pmywChNQ5m).
- Use the appropriate support forum!
