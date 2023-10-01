
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
        }
	})

end

