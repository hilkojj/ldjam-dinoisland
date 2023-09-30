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

    setUpdateFunction(levelRestarter, 0.1, function()
        if _G.queueRestartLevel then
            restartLevel() -- replace with gameOver later
            _G.queueRestartLevel = false
        end
    end)
end