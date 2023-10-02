
_G.titleScreen = false
_G.cutScene = true
_G.introScreen = false
_G.outroScreen = true

if not _G.eggCounter then
    -- for debugging:
    _G.eggCounter = 6
end

onEvent("BeforeDelete", function()
    print("outro done..")
end)

setComponents(createEntity(), {
    UIElement {
        absolutePositioning = true
    },
    UIContainer {
        --nineSliceSprite = "sprites/ui/hud_border",
        fillRemainingParentHeight = true,
        fillRemainingParentWidth = true,

        zIndexOffset = -10
    }
})

function startScript()
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

            fixedWidth = 320,
            fixedHeight = 96,
            centerAlign = false
        }
    })

    local textField = createChild(popup, "speech_text")

    applyTemplate(textField, "Text", {
        text = "...",
        waving = true,
        wavingFrequency = 0.03,
        wavingSpeed = 10,
        wavingAmplitude = 3,
        lineSpacing = 4
    })

    local script = {}

    if _G.eggCounter <= 3 then
        -- lose
        script = {
            {
                text = "If I would've done this, I would have collected\nway more!",
                audio = "sounds/voicelines/lose_line_1",
                duration = 4
            },
            {
                text = "Anyway, lets take them back to the future,\nthey cannot hatch here! They deserve unlimited\nspace...",
                audio = "sounds/voicelines/lose_line_2",
                duration = 6.,
                func = "secondOutroCamPath"
            }
        }
    else
        -- win
        script = {
            {
                text = "Oof! That was intense! It sure looks like\nI rescued the eggs, just in time!",
                audio = "sounds/voicelines/win_line_1",
                duration = 5
            },
            {
                text = "Lets take them back to the future where\nI can give them unlimited space!",
                audio = "sounds/voicelines/win_line_2",
                duration = 5,
                func = "secondOutroCamPath"
            }
        }
    end

    local scriptI = 0

    function continueBtn()
        local btn = createChild(popup, "continue_btn")
        local continue = function()
            component.DespawnAfter.getFor(btn).time = 0
            nextScriptEntry()
        end
        applyTemplate(btn, "Button", {
            text = "[Space]",
            action = continue
        })
        setComponents(btn, {
            UIElement {
                absolutePositioning = true,
                absoluteHorizontalAlign = 2,
                absoluteVerticalAlign = 2,
                renderOffset = ivec2(-20, -2)
            }
        })
        listenToKey(btn, gameSettings.keyInput.jump, "jump_key")
        onEntityEvent(btn, "jump_key_pressed", continue)
    end

    function onScriptEnd()
        --setComponents(createEntity(), {
        --    DespawnAfter {
        --        time = 3
        --    },
        --    SoundSpeaker {
        --        sound = "sounds/voicelines/boy_hurt_2",
        --        volume = .5,
        --        pitch = 1.2
        --    },
        --})
        component.DespawnAfter.getFor(popup).time = 0
        setTimeout(createEntity(), 6.0, function()
            if screenTransitionStarted then
                return
            end

            startScreenTransition("transitions/screen_transition_egg", "shaders/ui/transition_cutoff")

            onEvent("ScreenTransitionStartFinished", function()

                closeActiveScreen()
                openScreen("scripts/ui_screens/StartupScreen")
            end)
        end)
    end

    function nextScriptEntry()

        if scriptI == #script then
            onScriptEnd()
            return
        end

        scriptI = scriptI + 1

        function spawnAudio()
            setComponents(createEntity(), {
                DespawnAfter {
                    time = 20,
                },
                SoundSpeaker {
                    sound = script[scriptI].audio,
                    volume = 1
                },
            })
        end

        if script[scriptI].delay then
            setTimeout(popup, script[scriptI].delay, spawnAudio)
        else
            spawnAudio()
        end
        if script[scriptI].func then
            _G[script[scriptI].func]()
        end

        component.TextView.getFor(textField).text = script[scriptI].text

        setTimeout(popup, script[scriptI].duration, function()
            if scriptI == #script then
                onScriptEnd()
            else
                continueBtn()
            end
        end)
    end

    nextScriptEntry()

end
_G.startScript = startScript

endScreenTransition("transitions/screen_transition0", "shaders/ui/transition_cutoff")
loadOrCreateLevel("assets/levels/default_level.lvl")
