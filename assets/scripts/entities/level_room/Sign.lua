
persistenceMode(TEMPLATE | ARGS, {"Transform"})

loadModels("assets/models/sign.glb", false)

masks = include("scripts/entities/level_room/_masks")

function create(sign)
    setName(sign, "sign")

    component.Transform.getFor(sign)

    setComponents(sign, {
        RenderModel {
            modelName = "sign",
            visibilityMask = masks.NON_PLAYER
        },
        ShadowCaster(),
    })


    setTimeout(sign, .1, function()
        local cam = getByName("3rd_person_camera")
        if valid(cam) then
            component.LookAt.getFor(sign).entity = cam
        end
    end)
end

