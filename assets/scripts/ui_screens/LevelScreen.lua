
_G.hudScreen = currentEngine

onEvent("BeforeDelete", function()
    loadOrCreateLevel(nil)
    if _G.hudScreen == currentEngine then
        _G.hudScreen = nil
    end
end)

if _G.levelToLoad == nil then
    error("_G.levelToLoad is nil")
end

applyTemplate(createEntity(), "LevelRestarter")

loadOrCreateLevel(_G.levelToLoad)

setComponents(createEntity(), {
    UIElement(),
    TextView {
        text = " Dino Island!",
        fontSprite = "sprites/ui/default_font"
    }
})
