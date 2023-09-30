
masks = include("scripts/entities/level_room/_masks")

loadRiggedModels("assets/models/dodo.glb", false)

function create(dodo)
    setName(dodo, "dodo")

    setComponents(dodo, {
        Transform {
            position = vec3(0, 100, 0)
        },
        RenderModel {
            modelName = "Dodo",
            visibilityMask = masks.NON_PLAYER
        },
        Rigged {
            playingAnimations = {
                PlayAnimation {
                    name = "Walking",
                    influence = 1,
                    loop = true
                }
            }
        },
        ShadowCaster(),
        RigidBody {
            gravity = vec3(0, -30, 0),
            mass = 1,
            linearDamping = .1,
            angularAxisFactor = vec3(0),
            collider = Collider {
                bounciness = 0,
                frictionCoefficent = .3,
                collisionCategoryBits = masks.DYNAMIC_CHARACTER,
                collideWithMaskBits = masks.STATIC_TERRAIN | masks.SENSOR,
                registerCollisions = true
            }
        },
        SphereColliderShape {
            radius = 0.8
        },
    })

end

