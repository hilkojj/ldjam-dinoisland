
_G.titleScreen = false
_G.cutScene = true
_G.introScreen = true

onEvent("BeforeDelete", function()
    print("cutscene done..")
end)

function startLevel()
    if screenTransitionStarted then
        return
    end

    startScreenTransition("transitions/screen_transition_egg", "shaders/ui/transition_cutoff")

    onEvent("ScreenTransitionStartFinished", function()

        closeActiveScreen()
        openScreen("scripts/ui_screens/LevelScreen")
    end)
end

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

    local script = {
        {
            text = "Woopsie doopsie! Looks like we just\ntravelled 60 million years back in time!",
            audio = "sounds/voicelines/intro_line_1",
            duration = 4
        },
        {
            text = "Just before the great moment in earth's\nhistory where all dinosaurs were about to be\ndrowned by the great flood.",
            audio = "sounds/voicelines/intro_line_2",
            duration = 5
        },
        {
            text = "Oh, it seems I brought you along with me!",
            audio = "sounds/voicelines/intro_line_3",
            duration = 2
        },
        {
            text = "Well, if you're here, could you help me collect\ndinosaur eggs and bring them to my ship?",
            audio = "sounds/voicelines/intro_line_4",
            duration = 4
        },
        {
            text = "If you hurry, we can save the species by\ntaking them back to the future!",
            audio = "sounds/voicelines/professor_hurry_1",
            duration = 3
        },
        {
            text = "Good luck adventurer!",
            audio = "sounds/voicelines/professor_reaction_2",
            duration = 1
        },
    }

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
        startLevel()
    end

    function nextScriptEntry()

        if scriptI == #script then
            onScriptEnd()
            return
        end

        scriptI = scriptI + 1

        setComponents(createEntity(), {
            DespawnAfter {
                time = 20,
            },
            SoundSpeaker {
                sound = script[scriptI].audio,
                volume = 1
            },
        })

        component.TextView.getFor(textField).text = script[scriptI].text

        setTimeout(popup, script[scriptI].duration, function()
            continueBtn()
        end)
    end

    nextScriptEntry()

end
_G.startScript = startScript

endScreenTransition("transitions/screen_transition0", "shaders/ui/transition_cutoff")
loadOrCreateLevel("assets/levels/default_level.lvl")
