for _, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  recipes["rail-chain-signal"].enabled = technologies["rail-signals"].researched

  if technologies["tanks"].researched then
    recipes["explosive-cannon-shell"].enabled = true
    recipes["cannon-shell"].reload()
    recipes["explosive-cannon-shell"].reload()
  end
end