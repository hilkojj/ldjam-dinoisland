
masks = include("scripts/entities/level_room/_masks")

loadModels("assets/models/kiphetmeestvulzijdigestukjevleeskip.glb", false)

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function create(meal)
    setName(meal, "meal")

    setComponents(meal, {
        Transform {
            position = vec3(0, 100, 0),
            scale = vec3(0.5, 0.5, 0.5)
        },
        RenderModel {
            modelName = "kiphetmeestvulzijdigestukjevleeskip",
            visibilityMask = masks.NON_PLAYER
        },
        ShadowCaster(),
        RigidBody {
            gravity = vec3(0, -30, 0),
            mass = 1,
            linearDamping = .1,
            angularAxisFactor = vec3(0),
            collider = Collider {
                bounciness = 0,
                frictionCoefficent = .1,
                collisionCategoryBits = masks.DYNAMIC_CHARACTER,
                collideWithMaskBits = masks.STATIC_TERRAIN | masks.SENSOR,
                registerCollisions = true
            }
        },
        SphereColliderShape {
            radius = 0.3
        },
        CharacterMovement {
            walkSpeed = 18,
            walkDirInput = vec2(0, 1)
        }
    })

    onEntityEvent(meal, "Collision", function (col)
        if not component.Child.has(col.otherEntity) or component.RenderModel.has(col.otherEntity) then
            return
        end
        local dino = component.Child.getFor(col.otherEntity).parent

        if  not component.RenderModel.has(dino) or component.RenderModel.getFor(dino).modelName ~= "Dino" then
            return
        end
        local nest = getChild(dino, "nest")

        component.RigidBody.remove(meal)
        component.CharacterMovement.remove(meal)

        component.Transform.animate(meal, "position", component.Transform.getFor(nest).position + vec3(5 + randomFloat(-0.5, 0.5), 1 + randomFloat(-0.2, 0.2), randomFloat(-1, 1)), 0.5, "pow2Out", function()
            currentRoom.dinoMealStarters[dino](meal)
        end)
    end)

end

