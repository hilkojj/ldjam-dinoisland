
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

    local startPos = vec3(-152, 104, -92)
    local finalPos = vec3(76, 140, -47)

    component.Transform.getFor(prof).position = startPos

    local eggEntities = {}
    _G.byeProf = function()
        setTimeout(prof, 3.6, function()
            applyTemplate(createEntity(), "Flash")
        end)
        component.Transform.animate(prof, "position", finalPos, 4, "pow4In", function()
            component.DespawnAfter.getFor(prof).time = 0

            for i = 1, #eggEntities do
                component.TransformChild.remove(eggEntities[i])
                component.Transform.animate(eggEntities[i], "position", component.Transform.getFor(eggEntities[i]).position - vec3(0, 40, 0), 3, "pow2In")
            end
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

    for i = 1,_G.eggCounter do
        local egg = createEntity()
        eggEntities[#eggEntities + 1] = egg
        applyTemplate(egg, "Egg")
        component.TransformChild.getFor(egg).parentEntity = ship
        component.TransformChild.getFor(egg).rotation = true
        component.TransformChild.getFor(egg).offset.position = _G.eggOffsets[i] + vec3(0, 0.2, 0)
    end
end

