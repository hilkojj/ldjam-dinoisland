
masks = include("scripts/entities/level_room/_masks")

function create(boy)

    setName(boy, "boy_outro")

    local rot1 = quat:new():setIdentity()
    rot1.y = 62
    setComponents(boy, {
        Transform {
            position = vec3(32, 111, -56),
            rotation = rot1
        },
        RenderModel {
            modelName = "Boy",
            visibilityMask = masks.NON_PLAYER
        },
        Rigged {
            playingAnimations = {
                PlayAnimation {
                    name = "Idle2",
                    influence = 1,
                    loop = true
                },
            }
        },
        ShadowCaster()
    })
end

