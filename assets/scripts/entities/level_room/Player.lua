
function create(player)

    if not _G.titleScreen and not _G.cutScene then
        applyTemplate(player, "Boy")
    else
        setMainCamera(getByName("cine_cam"))
        applyTemplate(player, "Title")
    end

end
