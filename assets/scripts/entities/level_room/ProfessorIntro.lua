
masks = include("scripts/entities/level_room/_masks")

function create(prof)
    setName(prof, "prof")

    applyTemplate(createEntity(), "Flash")

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
            entity = getByName("intro_cam")
        },
        SoundSpeaker {
            sound = "sounds/time_travel",
            volume = 0.1
        },
        PositionedAudio()
    })

    local ship = createChild(prof, "ship")
    applyTemplate(ship, "Ship")
    component.TransformChild.getFor(ship).parentEntity = prof
    component.TransformChild.getFor(ship).offset.position = vec3(0, -2, 0)

    local startPos = vec3(400, 80, 145)
    local finalPos = vec3(-158, 2.5, 441)

    component.Transform.getFor(prof).position = startPos
    component.Transform.animate(prof, "position", finalPos, 4, "pow4Out")

    _G.spawnBoyIntro = function()
        local boy = createEntity()
        applyTemplate(boy, "BoyIntro")
    end
end

