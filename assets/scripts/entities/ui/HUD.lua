
function create(hud, args)

    setName(hud, "hud")

    setComponents(hud, {
        UIElement {
            absolutePositioning = true
        },
        UIContainer {
        --[[
            nineSliceSprite = "sprites/ui/hud_border",
        ]]--

            fillRemainingParentHeight = true,
            fillRemainingParentWidth = true,

            zIndexOffset = -10,
            centerAlign = true
        }
    })
    local mealCountContainer = createEntity()
    setName(mealCountContainer, "mealCountContainer")
    setComponents(mealCountContainer, {
        UIElement {
            absolutePositioning = true,
            absoluteHorizontalAlign = 0,
            absoluteVerticalAlign = 0,
            renderOffset = ivec2(24, 24)
        },
        UIContainer {
            fixedWidth = 100,
            fixedHeight = 100,
            centerAlign = false
        }
    })

    local mealCountIcon = createChild(mealCountContainer, "meal count icon")
    setComponents(mealCountIcon, {
        UIElement {
            renderOffset = ivec2(-12, -28)
        },
        AsepriteView {
            sprite = "sprites/ui/meal",
            frame = 1
        }
    })
    local mealCountText = createChild(mealCountContainer, "meal count text")
    applyTemplate(mealCountText, "Text")
    component.UIElement.getFor(mealCountText).startOnNewLine = true
    component.TextView.getFor(mealCountText).text = "0x"

    local featherCountContainer = createEntity()
    setName(featherCountContainer, "featherCountContainer")
    setComponents(featherCountContainer, {
        UIElement {
            absolutePositioning = true,
            absoluteHorizontalAlign = 0,
            absoluteVerticalAlign = 0,
            renderOffset = ivec2(24 + 64, 24)
        },
        UIContainer {
            fixedWidth = 100,
            fixedHeight = 100,
            centerAlign = false
        }
    })

    local featherCountIcon = createChild(featherCountContainer, "feather count icon")
    setComponents(featherCountIcon, {
        UIElement {
            renderOffset = ivec2(-12, -28)
        },
        AsepriteView {
            sprite = "sprites/ui/meal",
            frame = 0
        }
    })
    local featherCountText = createChild(featherCountContainer, "feather count text")
    applyTemplate(featherCountText, "Text")
    component.UIElement.getFor(featherCountText).startOnNewLine = true
    component.TextView.getFor(featherCountText).text = "0x"

    local throwEggContainer = createEntity()
    setName(throwEggContainer, "throwEggContainer")
    setComponents(throwEggContainer, {
        UIElement {
            absolutePositioning = true,
            absoluteHorizontalAlign = 1,
            absoluteVerticalAlign = 0,
            renderOffset = ivec2(0, 24)
        },
        UIContainer {
            fixedWidth = 100,
            fixedHeight = 100,
            centerAlign = true
        }
    })

    local throwEggIcon = createChild(throwEggContainer, "throwEggIcon")
    setComponents(throwEggIcon, {
        UIElement {
            renderOffset = ivec2(0, -28)
        },
        AsepriteView {
            sprite = "sprites/ui/meal",
            frame = 3
        }
    })

    setUpdateFunction(mealCountContainer, 0.05, function()
        component.TextView.getFor(mealCountText).text = _G.mealsToThrow.."x"
        local frame = 1
        if _G.mealsToThrow == 0 then
            component.TextView.getFor(mealCountText).mapColorTo = colors.rainbow_red
        else
            component.TextView.getFor(mealCountText).mapColorTo = colors.string
            if not _G.holdingEgg then
                frame = 2
            end
        end
        component.AsepriteView.getFor(mealCountIcon).frame = frame
    end)

    setUpdateFunction(featherCountContainer, 0.05, function()
        component.TextView.getFor(featherCountText).text = _G.featherScore.."x"
    end)

    setUpdateFunction(throwEggContainer, 0.05, function()
        if _G.canThrowEgg then
            component.AsepriteView.getFor(throwEggIcon).frame = 3
        else
            component.AsepriteView.getFor(throwEggIcon).frame = 4
        end
    end)

    _G.showGameOverPopup = function(won)
        destroyEntity(mealCountContainer)
        destroyEntity(featherCountContainer)

        local popup = createEntity()
        setName(popup, "gameover popup")
        setComponents(popup, {
            UIElement {
                absolutePositioning = true,
                absoluteHorizontalAlign = 1,
                absoluteVerticalAlign = 2,
                renderOffset = ivec2(0, 0)
            },
            UIContainer {
                nineSliceSprite = "sprites/ui/9slice",

                fixedWidth = 200,
                fixedHeight = 130,
                centerAlign = true
            }
        })
        
        if not won then
            applyTemplate(createChild(popup, "gameovertext"), "Text", {
                text = "You drowned!\n",
                waving = true,
                wavingFrequency = .2,
                wavingSpeed = 20,
                wavingAmplitude = 2,
                lineSpacing = 0
            })
            if _G.timesDied > 1 then

                applyTemplate(createChild(popup), "Text", {
                    text = "Again.. For the ",
                    color = colors.brick
                })

                local th = "th"
                if _G.timesDied == 2 then
                    th = "nd"
                elseif _G.timesDied == 3 then
                    th = "rd"
                elseif _G.timesDied == 69 then
                    th = "th ;-)"
                end

                applyTemplate(createChild(popup), "Text", {
                    text = math.floor(_G.timesDied)..th,
                    color = colors.rainbow_red
                })
                applyTemplate(createChild(popup), "Text", {
                    text = " time..",
                    color = colors.brick
                })
            else
                applyTemplate(createChild(popup), "Text", {
                    text = "\n",
                    color = colors.brick
                })
            end


            --[[
            applyTemplate(createChild(popup, "scoretext"), "Text", {
                text = "Your score: "..totalEnergyEver.."\n",
                lineSpacing = 10,
                color = colors.brick--5,
            })]]--
        

            setTimeout(popup, 3, function()
                applyTemplate(createChild(popup, "retrybutton"), "Button", {
                    text = "Retry",
                    action = _G.retryLevel,
                    center = true,
                    fixedWidth = 80,
                    newLine = true
                })
            end)
        else

            applyTemplate(createChild(popup, "gameovertext"), "Text", {
                text = "You won the game...\nIt was inevitable...",
                waving = true,
                wavingFrequency = .04,
                wavingSpeed = 10,
                wavingAmplitude = 3,
                lineSpacing = 0
            })

            --[[
            applyTemplate(createChild(popup, "scoretext"), "Text", {
                text = "Your time: "..getTimeString().."\n",
                lineSpacing = 10,
                color = 2,
            })
            ]]--

            --[[
            applyTemplate(createChild(popup, "scoretext"), "Text", {
                text = "Your score: "..totalEnergyEver.."\n",
                lineSpacing = 10,
                color = colors.brick--5,
            })]]--
        

        end
        setTimeout(popup, 3, function()
            applyTemplate(createChild(popup, "menubutton"), "Button", {
                text = "Main menu",
                action = _G.goToMainMenu,
                newLine = true,
                center = true,
                fixedWidth = 80
            })
        end)
    end

end