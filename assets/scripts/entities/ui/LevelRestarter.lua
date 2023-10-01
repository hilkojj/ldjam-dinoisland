function create(levelRestarter)
    listenToKey(levelRestarter, gameSettings.keyInput.retryLevel, "retry_key")
    local restartLevel = function()
        closeActiveScreen()
        openScreen("scripts/ui_screens/LevelScreen")
    end
    onEntityEvent(levelRestarter, "retry_key_pressed", restartLevel)

    local gameOver = function()
        closeActiveScreen()
        openScreen("scripts/ui_screens/GameOverScreen")
    end

    local updatesSindsRestart = 0
    setUpdateFunction(levelRestarter, 0.1, function()
        if _G.queueRestartLevel then
            if updatesSindsRestart == 0 then
                setComponents(createEntity(), {
                    DespawnAfter {
                        time = 1
                    },
                    SoundSpeaker {
                        sound = "sounds/voicelines/boy_drowning_"..math.random(1,4),
                        volume = .5,
                        pitch = 1.2
                    },
                })
            end

            if updatesSindsRestart >= 25 then
                restartLevel() -- replace with gameOver later
                _G.queueRestartLevel = false
            end

            updatesSindsRestart = updatesSindsRestart + 1;
        end
    end)
end