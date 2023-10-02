
_G.hudScreen = currentEngine
_G.titleScreen = false
_G.cutScene = false
_G.introScreen = false
_G.outroScreen = false

onEvent("BeforeDelete", function()
    loadOrCreateLevel(nil)
    if _G.hudScreen == currentEngine then
        _G.hudScreen = nil
    end
end)

_G.retryLevel = function()
    if screenTransitionStarted then
        return
    end

    startScreenTransition("transitions/screen_transition_egg", "shaders/ui/transition_cutoff")
    setComponents(createEntity(), {
        SoundSpeaker {
            sound = "sounds/voicelines/professor_game_over_1",
            volume = .8
        },
    })
    onEvent("ScreenTransitionStartFinished", function()

        closeActiveScreen()
        openScreen("scripts/ui_screens/LevelScreen")
    end)
end

_G.goToMainMenu = function()
    if screenTransitionStarted then
        return
    end

    startScreenTransition("transitions/screen_transition0", "shaders/ui/transition_cutoff")
    onEvent("ScreenTransitionStartFinished", function()

        closeActiveScreen()
        openScreen("scripts/ui_screens/StartupScreen")
    end)
end

local levelRestarter = createEntity()
listenToKey(levelRestarter, gameSettings.keyInput.retryLevel, "retry_key")
onEntityEvent(levelRestarter, "retry_key_pressed", _G.retryLevel)

loadOrCreateLevel("assets/levels/default_level.lvl")

applyTemplate(createEntity(), "HUD")

endScreenTransition("transitions/screen_transition1", "shaders/ui/transition_cutoff")
