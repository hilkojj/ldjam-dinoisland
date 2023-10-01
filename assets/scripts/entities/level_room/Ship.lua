
masks = include("scripts/entities/level_room/_masks")

loadRiggedModels("assets/models/ship.glb", false)

function create(ship)
    setName(ship, "ship")

    setComponents(ship, {
        Transform {
        },
        RenderModel {
            modelName = "Ship",
            visibilityMask = masks.NON_PLAYER
        },
        Rigged {
            playingAnimations = {
                PlayAnimation {
                    name = "Idle",
                    influence = 1.0,
                    loop = true
                }
            }
        },
        ShadowCaster(),
        ShadowReceiver(),
    })
    local lamp = createChild(ship, "lamp")
    setComponents(lamp, {
        Transform(),
        TransformChild {
            parentEntity = ship,
            offset = Transform {
                position = vec3(-1, 3.5, 0)
            },
        },
        PointLight {
            color = vec3(0, 10, 0)
        }
    })

    --[[
    local eggSensor = createChild(ship, "egg_sensor")
    setName(eggSensor, "egg_sensor")
    setComponents(eggSensor, {
        Transform {

        },
        TransformChild {
            parentEntity = ship
        },
        GhostBody {
            collider = Collider {
                collisionCategoryBits = masks.SENSOR,
                collideWithMaskBits = masks.DYNAMIC_CHARACTER,
                registerCollisions = true
            }
        },
        SphereColliderShape {
            radius = 48
        }
    })]]--

end

