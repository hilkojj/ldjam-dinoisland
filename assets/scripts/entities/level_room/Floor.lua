
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
        BoxColliderShape {
            halfExtents = vec3(1000, 0, 1000)
        },
        RenderModel {
            modelName = "Floor"
        },
        ShadowReceiver()
	})

end

