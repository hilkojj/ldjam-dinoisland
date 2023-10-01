
masks = include("scripts/entities/level_room/_masks")

loadModels("assets/models/dino.glb", false)
loadModels("assets/models/nest.glb", false)

persistenceMode(TEMPLATE | ARGS, {"Transform"})

function create(dino)
    setName(dino, "dino")

    component.Transform.getFor(dino)

    setComponents(dino, {
        RenderModel {
            modelName = "Dino",
            visibilityMask = masks.NON_PLAYER
        },
        --[[
        Rigged {
            playingAnimations = {
                PlayAnimation {
                    name = "Walking",
                    influence = 1,
                    loop = true
                }
            }
        },]]--
        ShadowCaster(),
        RigidBody {
            mass = 0,
            collider = Collider {
                bounciness = 0,
                frictionCoefficent = .3,
                collisionCategoryBits = masks.STATIC_TERRAIN,
                collideWithMaskBits = masks.DYNAMIC_CHARACTER | masks.PLAYER,
                registerCollisions = true
            }
        },
        SphereColliderShape {
            radius = 0.8
        }
    })

    local nest = createChild(dino, "nest")
    setComponents(nest, {
        Transform {

        },
        TransformChild {
            parentEntity = dino,
            rotation = false
        },
        RenderModel {
            modelName = "nest",
            visibilityMask = masks.NON_PLAYER
        },
        ShadowCaster(),
    })

end

