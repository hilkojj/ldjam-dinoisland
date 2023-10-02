
masks = include("scripts/entities/level_room/_masks")

loadRiggedModels("assets/models/egg.glb", false)

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function create(egg)
    setName(egg, "egg")

    local dir = vec3(randomFloat(-1, 1), 0.01, randomFloat(-1, 1))
    if dir.z > -0.5 and dir.z < 0 then
        dir.z = -0.5
    end
    if dir.z < 0.5 and dir.z >= 0 then
        dir.z = 0.5
    end
    local dirLen = dir:length()
    dir = vec3(dir.x / dirLen, 0, dir.z / dirLen)

    setComponents(egg, {
        Transform {},
        TransformChild {
            rotation = false,
            offset = Transform {
                position = dir * vec3(3.3) + vec3(0, 0.8, 0),
                scale = vec3(1.3)
            }
        },
        RenderModel {
            modelName = "egg",
            visibilityMask = masks.NON_PLAYER
        },
        Rigged {
            playingAnimations = {
                PlayAnimation {
                    name = "idle",
                    influence = 1,
                    loop = true,
                    timeMultiplier = 0.5
                }
            }
        },
        CustomShader {
            vertexShaderPath = "shaders/rigged.vert",
            fragmentShaderPath = "shaders/default.frag",
            defines = {DINO = "1"},
            uniformsVec3 = {dinoColorA = vec3(0.95, 0.95, 0.9), dinoColorB = vec3(0.7, 0.2, 1)}
        },
        ShadowCaster(),
        GhostBody {
            collider = Collider {
                collisionCategoryBits = masks.SENSOR,
                collideWithMaskBits = masks.DYNAMIC_CHARACTER,
                registerCollisions = true
            }
        },
        SphereColliderShape {
            radius = 1.5
        },
    })

    local pickedUp = false

    onEntityEvent(egg, "Collision", function (col)

        if col.otherEntity == _G.player and not hit and #col.contactPoints > 0 and not _G.holdingEgg then

            _G.holdingEgg = true
            _G.holdingEggEntity = egg
            pickedUp = true

            component.TransformChild.remove(egg)
            component.TransformChild.getFor(egg).parentEntity = _G.player
            component.TransformChild.getFor(egg).offset.position = vec3(0, -0.1, -0.9)
            component.TransformChild.getFor(egg).offset.scale = vec3(1.3)

            component.Rigged.getFor(egg).playingAnimations = {
                PlayAnimation {
                    name = "idle",
                    influence = 0.3,
                    loop = true
                },
                PlayAnimation {
                    name = "Holding",
                    influence = 1,
                    loop = true
                }
            }
        end

    end)

end

