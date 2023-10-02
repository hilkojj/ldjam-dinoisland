
persistenceMode(TEMPLATE | ARGS, {"Transform"})

collisionMasks = include("scripts/entities/level_room/_masks")

function create(lava)

    setName(lava, "lava")

    component.Transform.getFor(lava)
	
	setComponents(lava, {
        CustomShader {
            vertexShaderPath = "shaders/default.vert",
            fragmentShaderPath = "shaders/dinoisland/lava.frag"
        },
        GhostBody {
            collider = Collider {
                collisionCategoryBits = collisionMasks.SENSOR,
                collideWithMaskBits = collisionMasks.DYNAMIC_CHARACTER,
                registerCollisions = true
            }
        },
        BoxColliderShape {
            halfExtents = vec3(20, 1, 20)
        },
        RenderModel {
            modelName = "Floor"
        }
	})

    local hit = false
    onEntityEvent(lava, "Collision", function (col)

        if col.otherEntity == _G.player and not hit and #col.contactPoints > 0 then
            hit = true
            _G.diedByLava = true
            _G.queueRestartLevel = true
            local cam = getByName("3rd_person_camera")
            if valid(cam) then
                component.ThirdPersonFollowing.remove(cam)
            end
        end
    end)
end

