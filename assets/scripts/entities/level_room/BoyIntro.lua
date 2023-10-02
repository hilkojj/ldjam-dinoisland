
masks = include("scripts/entities/level_room/_masks")

function create(boy)

    setName(boy, "boy_intro")

    applyTemplate(createEntity(), "Flash")
    local rot1 = quat:new():setIdentity()
    rot1.y = 62
    setComponents(boy, {
        Transform {
        },
        TransformChild {
            parentEntity = getByName("prof"),
            offset = Transform {
                position = vec3(3, 0, -1),
                rotation = rot1
            },
        },
        RenderModel {
            modelName = "Boy",
            visibilityMask = masks.NON_PLAYER
        },
        --[[
        CustomShader {
            vertexShaderPath = "shaders/default.vert",
            fragmentShaderPath = "shaders/default.frag",
            defines = {TEST = "1"}
        },]]--
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

