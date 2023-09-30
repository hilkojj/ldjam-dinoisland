
persistenceMode(TEMPLATE | ARGS, {"Transform"})

collisionMasks = include("scripts/entities/level_room/_masks")

loadModels("assets/models/island.glb", false)
loadColliderMeshes("assets/models/island.obj", false)

function create(e)
	
    setName(e, "island")
	
	setComponents(e, {
		RigidBody {
			mass = 0,
			collider = Collider {
				bounciness = 1,
				frictionCoefficent = 1,
				collisionCategoryBits = collisionMasks.STATIC_TERRAIN,
				collideWithMaskBits = collisionMasks.DYNAMIC_CHARACTER | collisionMasks.DYNAMIC_PROPS
			}
		},
		ConcaveColliderShape {
			meshName = "island"
		},
		RenderModel {
			modelName = "island"
		},
		ShadowReceiver()
	})

	component.Transform.getFor(e)

end
