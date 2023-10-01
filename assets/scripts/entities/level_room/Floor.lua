
persistenceMode(TEMPLATE | ARGS, {"Transform"})

collisionMasks = include("scripts/entities/level_room/_masks")

function create(floor)

    setName(floor, "sea")
	
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

end

