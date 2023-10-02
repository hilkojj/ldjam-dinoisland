
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
    local energyMeter = createChild(hud, "energy meter")
    setComponents(energyMeter, {
        UIElement {
            --[[
            absolutePositioning = true,
            absoluteHorizontalAlign = 1,
            absoluteVerticalAlign = 0,
            renderOffset = ivec2(0, 0)
            ]]--
        },
        AsepriteView {
            sprite = "sprites/ui/energy_meter",
            loop = false
        }
        
    })

    --[[
    local hearts = {
        createChild(hud, "heart 0"),
        createChild(hud, "heart 1"),
        createChild(hud, "heart 2"),
        createChild(hud, "heart 3"),
    }
    for i, h in pairs(hearts) do

        setComponents(h, {
            UIElement {
                
                absolutePositioning = true,
                absoluteHorizontalAlign = 1,
                absoluteVerticalAlign = 0,
                renderOffset = ivec2(i * 16 - 40, -52)
            },
            AsepriteView {
                sprite = "sprites/ui/heart",
                loop = false
            }
        
        })

    end

    _G.updateHealthBar = function(left)
        
        for i = 4, left + 1, -1 do
            component.AsepriteView.getFor(hearts[i]).playingTag = 0
        end
        
    end

    function getTimeString()
	    local minutesStr = math.floor(getTime() / 60)..""
        local secsStr = math.floor(math.fmod(getTime(), 60))..""
        return (#minutesStr == 1 and "0"..minutesStr or minutesStr)..":"..(#secsStr == 1 and "0"..secsStr or secsStr)
    end


    local timeText = createChild(hud, "time text")
    applyTemplate(timeText, "Text", {
        text = "00:00",
        color = 2
    })
    setUpdateFunction(timeText, .5, function()
    
        component.TextView.getFor(timeText).text = getTimeString()
    
    end, false)
    ]]--


    _G.showGameOverPopup = function(won)
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