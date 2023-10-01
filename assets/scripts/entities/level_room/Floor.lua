
persistenceMode(TEMPLATE | ARGS, {"Transform"})

collisionMasks = include("scripts/entities/level_room/_masks")

function create(floor)

    setName(floor, "sea")

    _G.seaHeight = 0
	
	setComponents(floor, {
		Transform {
            position = vec3(0, 0, 0),
            scale = vec3(1000, 1, 1000)
        },
        CustomShader {
            vertexShaderPath = "shaders/default.vert",
            fragmentShaderPath = "shaders/dinoisland/water.frag"
        },
        RigidBody {
            mass = 0,
            collider = Collider {
                bounciness = 1,
                frictionCoefficent = 0.2,
                collisionCategoryBits = collisionMasks.WATER,
                collideWithMaskBits = collisionMasks.DYNAMIC_CHARACTER | collisionMasks.DYNAMIC_PROPS
            }
        },
        BoxColliderShape {
            halfExtents = vec3(1000, 0.1, 1000)
        },
        RenderModel {
            modelName = "Floor"
        },
        ShadowReceiver()
	})

    setUpdateFunction(floor, 0.05, function()
        local rise = 0.01

        local floorTransform = component.Transform.getFor(floor)

        if _G.player ~= nil and valid(_G.player) and component.CharacterMovement.has(_G.player) then
            local playerTransform = component.Transform.getFor(_G.player)
            local playerMovement = component.CharacterMovement.getFor(_G.player)

            if playerMovement.onGround then
                local yDiff = playerTransform.position.y - floorTransform.position.y
                if yDiff > 8 then
                    rise = rise + 0.03
                end
            end
        end

        floorTransform.position.y = floorTransform.position.y + rise
        _G.seaHeight = floorTransform.position.y
    end)
end

