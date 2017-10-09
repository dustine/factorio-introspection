local technology = {
  type = "technology",
  name = "introspection-satellite_telemetry",
  icon = "__base__/graphics/technology/mining-productivity.png",
  effects = {{
    type = "nothing",
    effect_key = "A THING"
  }},
  prerequisites = {"rocket-silo"},
  unit = {
    count = 250,
    ingredients = {
      {"science-pack-1", 1},
      {"science-pack-2", 1},
      {"science-pack-3", 1},
      {"production-science-pack", 1},
      {"high-tech-science-pack", 1},
      {"space-science-pack", 1},
    },
    time = 60
  },
  order = "z-a-a"
}

local input = {
  type = "custom-input",
  name = "introspection-satellite_telemetry",
  key_sequence = "CONTROL + E"
}

data:extend {technology, input}