
persistenceMode(TEMPLATE | ARGS, {"Transform"})

defaultArgs({
    setAsMain = false,
    name = ""
})

function create(cam, args)

    setComponents(cam, {
        CameraPerspective {
            fieldOfView = 75,
            nearClipPlane = .1,
            farClipPlane = 1000,
            visibilityMask = -1
        },
    })

    component.Transform.getFor(cam)

    if args.name ~= "" then
        if args.name == "3rd_person_camera" then
            setComponents(cam, { Transform() }) -- reset transform
        end
        setName(cam, args.name)
        end
    if args.setAsMain then
        setMainCamera(cam)
    end

end
