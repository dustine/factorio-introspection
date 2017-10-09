require "prototypes.technologies.satellite-telemetry"

local text ={
    type = "flying-text",
    name = "introspection-flying_text",
    flags = {"placeable-off-grid", "not-on-map"},
    time_to_live = 60,
    speed = 0.05
}
data:extend{text}