
_G.titleScreen = true
_G.cutScene = false
_G.introScreen = false
_G.outroScreen = false

_G.joinedSession = false

_G.timesDied = 0

startupArgs = getGameStartupArgs()
if not _G.joinedSession then

    saveGamePath = startupArgs["--single-player"] or "saves/default_save.dibdab"
    startSinglePlayerSession(saveGamePath)

    username = startupArgs["--username"] or "poopoo"
    joinSession(username, function(declineReason)

        tryCloseGame()
        error("couldn't join session: "..declineReason)
    end)
    _G.joinedSession = true
end

onEvent("BeforeDelete", function()
    print("startup screen done..")
end)

function startIntro()
    if screenTransitionStarted then
        return
    end

    startScreenTransition("transitions/screen_transition_egg", "shaders/ui/transition_cutoff")
    setComponents(createEntity(), {
        SoundSpeaker {
            sound = "sounds/voicelines/welcome",
            volume = 1
        },
    })
    onEvent("ScreenTransitionStartFinished", function()

        closeActiveScreen()
        openScreen("scripts/ui_screens/IntroScreen")
    end)
end

setComponents(createEntity(), {
    UIElement {
        absolutePositioning = true
    },
    UIContainer {
        nineSliceSprite = "sprites/ui/hud_border",
        fillRemainingParentHeight = true,
        fillRemainingParentWidth = true,

        zIndexOffset = -10
    }
})

local popup = createEntity()
setName(popup, "popup")
setComponents(popup, {
    UIElement {
        absolutePositioning = true,
        absoluteHorizontalAlign = 1,
        absoluteVerticalAlign = 2,
        renderOffset = ivec2(0, 10)
    },
    UIContainer {
        nineSliceSprite = "sprites/ui/9slice",

        fixedWidth = 200,
        fixedHeight = 100,
        centerAlign = true
    }
})

applyTemplate(createChild(popup, "gameovertext"), "Text", {
    text = "Rescue the Eggs!\n",
    waving = true,
    wavingFrequency = .04,
    wavingSpeed = 10,
    wavingAmplitude = 3,
    lineSpacing = 4
})

applyTemplate(createChild(popup, "cptext"), "Text", {
    text = "Ludum Dare 54 - 2023\n\n",
    color = 2
})


function difficultyBtn(name, difficulty)
    local btn = createChild(popup)
    applyTemplate(btn, "Button", {
        text = name,
        action = function()
            _G.difficulty = difficulty
            startIntro()
        end
    })
    component.UIElement.getFor(btn).margin = ivec2(0, 0)
end
--difficultyBtn("Easy", 6)
difficultyBtn("PLAY!", 9)
--difficultyBtn("Hell", 12)


endScreenTransition("transitions/screen_transition0", "shaders/ui/transition_cutoff")
loadOrCreateLevel("assets/levels/default_level.lvl")

--openScreen("scripts/ui_screens/OutroScreen")

