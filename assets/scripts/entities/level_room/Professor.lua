
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
            gravity = vec3(0),
            mass = 0,
            angularAxisFactor = vec3(0),
            collider = Collider {
                bounciness = 0,
                frictionCoefficent = .1,
                collisionCategoryBits = masks.STATIC_TERRAIN,
                collideWithMaskBits = masks.DYNAMIC_CHARACTER | masks.PLAYER,
                registerCollisions = true
            }
        },
        CapsuleColliderShape {
            sphereRadius = 1,
            sphereDistance = 2
        }
    })

end

