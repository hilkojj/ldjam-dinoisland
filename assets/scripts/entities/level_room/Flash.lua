
function create(flash)
    setName(flash, "flash")

    setComponents(flash, {
        SoundSpeaker {
            sound = "sounds/energy",
            volume = 3
        },
        DespawnAfter {
            time = 4
        },
        HDRExposure()
    })

    component.HDRExposure.animate(flash, "value", 7, 0.4, "pow2In", function()
        component.HDRExposure.animate(flash, "value", 1, 0.1, "pow2Out")
    end)
end

