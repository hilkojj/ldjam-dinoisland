
persistenceMode(TEMPLATE | ARGS, {"Transform"})

loadRiggedModels("assets/models/professor.glb", false)

masks = include("scripts/entities/level_room/_masks")

function create(prof)
    setName(prof, "prof")

    component.Transform.getFor(prof)

    setComponents(prof, {
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
        RigidBody {
            gravity = vec3(0, -30, 0),
            mass = 1,
            angularAxisFactor = vec3(0),
            collider = Collider {
                bounciness = 0,
                frictionCoefficent = .1,
                collisionCategoryBits = masks.DYNAMIC_CHARACTER,
                collideWithMaskBits = masks.STATIC_TERRAIN | masks.SENSOR | masks.WATER,
                registerCollisions = true
            }
        },
        CapsuleColliderShape {
            sphereRadius = 1,
            sphereDistance = 2
        }
    })

    local ship = createChild(prof, "ship")
    applyTemplate(ship, "Ship")
    component.TransformChild.getFor(ship).parentEntity = prof
    component.TransformChild.getFor(ship).offset.position = vec3(0, -2, 0)

end

