
masks = include("scripts/entities/level_room/_masks")

function create(prof)
    setName(prof, "prof_outro")

    setComponents(prof, {
        Transform {

        },
        RenderModel {
            modelName = "Professor",
            visibilityMask = masks.NON_PLAYER
        },
        Rigged {
            playingAnimations = {
                PlayAnimation {
                    name = "Idle",
                    influence = 1,
                    loop = true
                }
            }
        },
        ShadowCaster(),
        LookAt {
            entity = getByName("outro_cam")
        }
    })

    local ship = createChild(prof, "ship")
    applyTemplate(ship, "Ship")
    component.TransformChild.getFor(ship).parentEntity = prof
    component.TransformChild.getFor(ship).offset.position = vec3(0, -2, 0)

    local startPos = vec3(400, 80, 145)
    local finalPos = vec3(-158, 2.5, 441)

    component.Transform.getFor(prof).position = startPos

    _G.byeProf = function()
        component.Transform.animate(prof, "position", finalPos, 4, "pow4In", function()
            applyTemplate(createEntity(), "Flash")
        end)
        setComponents(prof, {
            SoundSpeaker {
                sound = "sounds/time_travel",
                volume = 0.1
            },
            PositionedAudio()
        })
        setComponents(createEntity(), {
            SoundSpeaker {
                sound = "sounds/voicelines/game_end",
                volume = .8
            },
        })
    end
end

