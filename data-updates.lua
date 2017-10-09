-- Satellite Telemetry
require("stdlib.utils.string")

local whitelist = ("radar radar-2 radar-3 radar-4 radar-5 advanced-radar"):split(" ")

local custom = settings.startup["introspection-enhanceable_radars"].value:split(" ")

for _, v in pairs(custom) do
  table.insert(whitelist, v)
end

for _, name in pairs(whitelist) do
  local radar = data.raw["radar"][name]
  if radar and radar.max_distance_of_sector_revealed > radar.max_distance_of_nearby_sector_revealed then
    -- radar.energy_per_sector = "3MJ"
    -- radar.energy_per_nearby_scan = "1MJ"
    -- radar.energy_usage = "3MW"

    if not radar.fast_replaceable_group then
      radar.fast_replaceable_group = "introspection-satellite_telemetry"
    end

    local enhanced = table.deepcopy(radar)
    -- make the composite name + localization
    if enhanced.localised_name then
      enhanced.localised_name = {"entity-name.introspection-satellite_telemetry", enhanced.localised_name}
    else
      enhanced.localised_name = {"entity-name.introspection-satellite_telemetry", {"entity-name."..enhanced.name}}
    end
    enhanced.name = "introspection-satellite_telemetry-"..enhanced.name

    -- TODO: Power!

    -- adjust its coverage and power usage statistics
    enhanced.max_distance_of_nearby_sector_revealed = enhanced.max_distance_of_sector_revealed
    enhanced.max_distance_of_sector_revealed = 0


    enhanced.order = "z-introspection-a"

    data:extend{enhanced}
  end
end