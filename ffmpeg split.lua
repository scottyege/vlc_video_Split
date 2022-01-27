-- "extension.lua"
-- VLC Extension basic structure (template): ----------------

-- Install
-- Windows: %APPDATA%/vlc/lua/extensions/basic.lua
-- Mac:     /Applications/VLC/.../lua/extensions/basic.lua
-- Linux:   ~/.local/share/vlc/lua/extensions/basic.lua

click=0

function descriptor()
    return {
        title = "ffmpeg Split LUL",
        version = "1.0",
        author = "",
        url = 'http://',
        shortdesc = "Split",
        description = "full description",
        capabilities = {"menu", "input-listener", "meta-listener", "playing-listener"}
    }
end

function activate()
    -- this is where extension starts
    -- for example activation of extension opens custom dialog box:
    create_dialog()
end
function deactivate()
    -- what should be done on deactivation of extension
end
function close()
    -- function triggered on dialog box close event
    -- for example to deactivate extension on dialog box close:
    -- vlc.deactivate()
end

function input_changed()
    -- related to capabilities={"input-listener"} in descriptor()
    -- triggered by Start/Stop media input event
end
function playing_changed()
    -- related to capabilities={"playing-listener"} in descriptor()
    -- triggered by Pause/Play madia input event
	--click=click+1
	--click_Action()
end
function meta_changed()
    -- related to capabilities={"meta-listener"} in descriptor()
    -- triggered by available media input meta data?
end

function menu()
    -- related to capabilities={"menu"} in descriptor()
    -- menu occurs in VLC menu: View > Extension title > ...
    return {"Menu item #1", "Menu item #2", "Menu item #3"}
end
-- Function triggered when an element from the menu is selected
function trigger_menu(id)
    if(id == 1) then
        --Menu_action1()
    elseif(id == 2) then
        --Menu_action2()
    elseif(id == 3) then
        --Menu_action3()
    end
end

--global variables--------------------------------------------------------------
gTsStart = 0
gTsEnd = 0
--------------------------------------------------------------------------------

-- Custom part, Dialog box example: -------------------------
function create_dialog()
    w = vlc.dialog("SPlit with ffmpeg")
    w1 = w:add_text_input("", 1, 1, 3, 1)

    startBtn = w:add_button("Start", clickRecordStartTime, 1, 2, 1, 1)
    startHtml = w:add_label("", 2, 2, 1, 1)
    endBtn = w:add_button("End", clickRecordEndTime, 1, 3, 1, 1)
    endHtml = w:add_label("", 2, 3, 1, 1)

    goBtn = w:add_button("Go", clickSplit, 1,4,3,1)
    w2 = w:add_html("debug", 1, 5, 3, 1)
    --w3 = w:add_button("Action!",click_Action, 1, 3, 1, 1)
    --w4 = w:add_button("Clear",click_Clear, 2, 3, 1, 1)
end

function click_Action()
    local input_string = w1:get_text()  -- local variable
    --local output_string = w2:get_text() .. input_string .. click .. vlc.playlist.status() .. "<br />"
	--local pitem = vlc.input.item() 
	--local output_string = pitem:name() .. "<br />" .. pitem:uri() .. "<br />"
	--local output_string = vlc.var.get(vlc.object.input(), "time")
    --w1:set_text("")
	--output_string = os.execute("ffmpeg")
	--output_string = string.format("uri:%s, name:%s", vlc.input.item():uri(), vlc.input.item():name())
    --output_string = getFullPath(vlc.input.item():uri())
    fullPath = getFullPath(vlc.input.item():uri())
    --dotIndex = string.len(xd) - string.find(string.reverse(xd), ".") + 1
    --dotIndex = string.find(string.reverse(xd), ".")
    newPath = getNewPath(fullPath, w1:get_text())
    output_string=string.format("%s<br/>%s",fullPath, newPath)
    --w2:set_text(output_string)
end

function click_Clear()
    --w2:set_text("")
end

function clickRecordStartTime()
    --gTsStart=toSecond(getCurrentPlayerTime())
    gTsStart=toFormatTime(getCurrentPlayerTime())
    startHtml:set_text(gTsStart)
end

function clickRecordEndTime()
    --gTsEnd=toSecond(getCurrentPlayerTime())
    gTsEnd=toFormatTime(getCurrentPlayerTime())
    endHtml:set_text(gTsEnd)
end

function clickSplit()
    local old = getFullPath(vlc.input.item():uri())
    local newPath = getNewPath(old, w1:get_text())
    local cmd = makeCommand(old, gTsStart, gTsEnd, newPath)
    Debug(cmd)
    os.execute(cmd)
end

-------function----------------------

function getCurrentPlayerTime()
    return vlc.var.get(vlc.object.input(), "time")
end

function getFullPath(uri)
	--https://stackoverflow.com/questions/24966228/vlc-lua-how-do-i-get-the-full-path-of-the-current-playing-item
   	uri = string.gsub(uri, '^file:///', '')
   	uri = string.gsub(uri, '/', '\\')
	uri = string.gsub(uri, '%%20', ' ')
	return uri
   	--strCmd = 'echo '..uri..' |clip'
   	--os.execute(strCmd)
end

function getNewPath(origin, mark)
    len = string.len(origin)
    dotIndex = len - string.find(string.reverse(origin), '%.') + 1

    pathToName = string.sub(origin, 1, dotIndex-1)
    extension = string.sub(origin, dotIndex)

    return pathToName .. '_' .. mark .. extension
end

function toSecond(microsecond)
    return microsecond * 0.000001;
end

function toFormatTime(microsecond)
    local total = toSecond(microsecond)
    local a = total%3600
    local hr = math.floor(total/3600)
    local min = math.floor(a/60)
    local sec = a%60
    return string.format("%02d:%02d:%02f",hr,min,sec);
end

function makeCommand(input, t1, t2, output)
    --ffmpeg -i [input] -ss [t1] -to [t2] -c copy [output]
    --https://trac.ffmpeg.org/wiki/Seeking
    return string.format("ffmpeg -ss %s -i \"%s\" -to %s -c copy \"%s\"", t1, input, t2, output)
end

function Debug(str)
    w2:set_text(str)
end