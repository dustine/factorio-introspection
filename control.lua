MOD = {
  name = "Introspection",
  if_name = "introspection",
  interfaces = {},
  -- config = require("config"),
  commands = {}
}

local Event = require 'stdlib.event.event'
-- local Game = require 'stdlib.game'

-- enhances the selected radar, if any
Event.register("introspection-satellite_telemetry", function(event)
  local player = game.players[event.player_index]
  -- if not(player and player.valid) then return end
  local radar = player.selected
  if not radar then return end
  local prototype = game.entity_prototypes["introspection-satellite_telemetry-"..radar.name]
  if not prototype then
    if radar.name:find("introspection%-satellite_telemetry%-") then
      radar.surface.create_entity {
        name = "introspection-flying_text",
        position = radar.position,
        text = {"text.introspection-already_enhanced"}
      }
    elseif radar.type == "radar" then
      radar.surface.create_entity {
        name = "introspection-flying_text",
        position = radar.position,
        text = {"text.introspection-cannot_enhance"},
        color = {r=1, g=0.5, b=0.5}
      }
    end
    return
  end
  if player.force.get_item_launched("satellite") <= global.used[player.force.name] then
    -- not enough free satellites, display error message
    radar.surface.create_entity {
      name = "introspection-flying_text",
      position = radar.position,
      text = {"text.introspection-no_free_satellites"},
      color = {r=1, g=0.5, b=0.5}
    }
    return
  end

  local backer_name = radar.backer_name
  local replacement = radar.surface.create_entity {
    name = prototype.name,
    position = radar.position,
    force = radar.force,
    fast_replace = true,
    player = player
  }

  if replacement then
    replacement.backer_name = backer_name
    global.used[player.force.name] = global.used[player.force.name] + 1
  end
end)

-- redeems the used satellite, if any
local function on_removed_boosted_radar(entity)
  if entity.name:find("introspection%-satellite_telemetry%-") then
    if global.used[entity.force.name] then
      global.used[entity.force.name] = global.used[entity.force.name] - 1
    end
  end
end

Event.register(defines.events.on_entity_died, function(event) on_removed_boosted_radar(event.entity) end)
Event.register(defines.events.on_preplayer_mined_item, function(event) on_removed_boosted_radar(event.entity) end)
Event.register(defines.events.on_robot_pre_mined, function(event) on_removed_boosted_radar(event.entity) end)

--[[ COMMANDS ]]

-- prints the free satellites for that faction
commands.add_command("introspection", {"command-help.introspection"}, function(event)
  local player = game.players[event.player_index]
  local used = global.used[player.force.name]
  if not used then
    global.used[player.force.name] = 0
    used = 0
  end
  player.print({"command.introspection", player.force.get_item_launched("satellite") - used})
end)

--[[ INIT ]]

local migrations = {}

local function on_load()
end

local function init_used()
  global.used = global.used or {}

  for name, _ in pairs(game.forces) do
    if not global.used[name] then
      global.used[name] = global.used[name] or 0
    end
  end
end

script.on_init(function ()
  global._changes = {}
  global._changes[game.active_mods[MOD.name]] = "0.0.0"

  -- skip migrations on map/mod init
  for _, ver in pairs (migrations) do
    global._changes[ver] = "0.0.0"
  end

  init_used()

  log(serpent.block(global.used))

  on_load()
end)

script.on_load(on_load)

script.on_configuration_changed(function (event)
  if event.data and event.data.mod_changes and event.data.mod_changes[MOD.name] then
    global._changes = global._changes or {}
    local new_version = event.data.mod_changes[MOD.name].new_version
    -- if not(event.mod_startup_settings_changed and global._changes[new_version]) then
      global._changes[new_version] = event.data.mod_changes[MOD.name].old_version or "0.0.0"
    -- end

    local migs = {}

    for _, ver in pairs (migrations) do
      if not global._changes[ver] then
        migs[ver](event)
        global._changes[ver] = event.data.mod_changes[MOD.name].old_version or "0.0.0"
      end
    end
  end
end)