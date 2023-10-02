
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
        }
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

    local seaSound = createEntity()

    setUpdateFunction(cam, 0.5, function()
        if getMainCamera() ~= cam then
            return
        end
        if not component.SoundSpeaker.has(seaSound) then
            setComponents(seaSound, {
                SoundSpeaker {
                    sound = "sounds/sea",
                    volume = 0.0
                }
            })
        end
        local yDiff = component.Transform.getFor(cam).position.y - _G.seaHeight
        local volume = math.max(0, math.min(1.0 - yDiff * 0.025))
        component.SoundSpeaker.getFor(seaSound).volume = volume * 0.2
    end)
end
