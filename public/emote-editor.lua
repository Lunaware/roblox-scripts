---@diagnostic disable: undefined-global

if not game.IsLoaded then game.Loaded:Wait() end

-- Variables
HttpService   = game:GetService("HttpService")
StarterPlayer = game:GetService("StarterPlayer")
Players       = game:GetService("Players")

author, project, branch = "Lunaware", "roblox-scripts", "main"

function httpImport(file)
    local success, result = pcall(loadstring(game:HttpGetAsync(string.format("https://raw.githubusercontent.com/%s/%s/%s/%s.lua", author, project, branch, file)), file.. ".lua"))

    return (success and result) or result and warn("Lunaware Engine Import Failed: ".. result)
end

repeat task.wait() until Players.LocalPlayer

LocalPlayer   = Players.LocalPlayer
Caches        = {EmoteSettings = {}}

json_decode   = function(input) return HttpService:JSONDecode(input) end
json_encode   = function(input) return HttpService:JSONEncode(input) end

if not StarterPlayer.UserEmotesEnabled then
    return
end

emote_table             = {}
cursor, response        = "", nil
roblox_emotes, choices  = {}, {}
contact = httpImport("public/contact")

function request_catalog_items()
    local request = string.format('https://catalog.roblox.com/v1/search/items/details?Category=%s&Subcategory=%s&IncludeNotForSale=true&Limit=30&Cursor=%s', json_decode(game:HttpGet('https://catalog.roblox.com/v1/categories')).AvatarAnimations, json_decode(game:HttpGet('https://catalog.roblox.com/v1/subcategories')).EmoteAnimations, cursor)

    response    = json_decode(game:HttpGet(request))
    cursor      = response.nextPageCursor

    for _, data in ipairs(response.data) do
        table.insert(emote_table, {data.name, data.id})

        _, data = nil
    end

    if cursor then
        request_catalog_items()
    end
end

request_catalog_items()

-- sort_emotes
table.sort(emote_table, function(a, b) return a[1] < b[1] end)

function string_spl (input, divider)
    local i = {}

    for str in string.gmatch(input, "([^".. (divider or "%s").. "]+)") do
        table.insert(i, str)
    end

    return i
end

function table_find (t, str)
    for index, data in pairs(t) do
        if string.sub(string.lower(index), 1, string.len(string.lower(str))) == string.lower(str) then
            return index, data
        end
    end

    return nil, nil
end

-- initialize_emotes
for _, emote in ipairs(emote_table) do
    table.insert(choices, emote[1])
    roblox_emotes[emote[1]] = {emote[2]}
end

-- initialize_client
local equipped_emotes = {
    {Slot = 1, Name = ""},
    {Slot = 2, Name = ""},
    {Slot = 3, Name = ""},
    {Slot = 4, Name = ""},
    {Slot = 5, Name = ""},
    {Slot = 6, Name = ""},
    {Slot = 7, Name = ""},
    {Slot = 8, Name = ""},
}

-- messaging_system
local Message = {Success = Color3.fromRGB(65,255,144), Info = Color3.fromRGB(226, 250, 6), Failed = Color3.fromRGB(255, 78, 65)}

function Message:Send(Text, Type)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[Luna's Emote System]: "..Text;
        Font = Enum.Font.SourceSansSemibold;
        Color = Message[Type];
        FontSize = Enum.FontSize.Size96;	
    })
end

-- caches
local autoload, settings

function Caches:CheckSettings()
    if Caches.EmoteSettings['autoload'] then
        settings    = json_decode(readfile("emote_system/emote_saves.txt")) or equipped_emotes

        return Caches.EmoteSettings['autoload'], settings
    end

    if isfolder('emote_system') then
        autoload        = readfile("emote_system/autoload.txt") or "false"
        settings        = json_decode(readfile("emote_system/emote_saves.txt")) or equipped_emotes

        equipped_emotes = settings

        Caches.EmoteSettings['autoload']    = autoload

        return Caches.EmoteSettings['autoload'], settings
	else
		Message:Send("Looks like it's your first time using my emote editor! To get a list of commands type /e help in the chat bar.", "Success")
    end

    return nil, nil
end

function Caches:ChangeEmote(Humanoid, Position, Emote)
    if not Humanoid or not Position or not Emote then
        return
    end

    for index, data in pairs(equipped_emotes) do
        if data.Slot == tonumber(Position) then
            equipped_emotes[index].Name = Emote
        end
    end

    Humanoid:SetEmotes(roblox_emotes)
    Humanoid:SetEquippedEmotes(equipped_emotes)
end

function Caches:FindHumanoidDescription(Humanoid)
    if not Humanoid then
        return
    end
        
    return Humanoid.HumanoidDescription or false
end

-- character_added
local autoload, settings
local Humanoid, HumanoidDescription

local function character_added(Character)
	repeat task.wait() until Character:FindFirstChildOfClass("Humanoid")

    Humanoid                = Character:FindFirstChildOfClass("Humanoid")
    autoload, settings      = Caches:CheckSettings()

    if Humanoid.RigType == Enum.HumanoidRigType.R15 then
        HumanoidDescription = Caches:FindHumanoidDescription(Humanoid)

        if autoload == "true" and HumanoidDescription then
            equipped_emotes = settings
        elseif HumanoidDescription then
            equipped_emotes = HumanoidDescription:GetEquippedEmotes()
        end

        if HumanoidDescription then
            for _, equipped_emote in pairs(equipped_emotes) do
                Caches:ChangeEmote(HumanoidDescription, equipped_emote.Slot, equipped_emote.Name)
                _, equipped_emote = nil
            end
        end
    end
end

local correct_text
local commands = {
    replace = function(position, ...)
        correct_text    = table.concat({...}, " ")

        print(correct_text)

        if not table_find(roblox_emotes, correct_text) then
            Message:Send("Failed to find an emote by the name of '".. correct_text .."'", "Failed")
            return
        end

        Caches:ChangeEmote(Caches:FindHumanoidDescription(Humanoid), position, table_find(roblox_emotes, correct_text))
        
        Message:Send("Changed Emote Slot ".. position.. " To [".. correct_text.. "]", "Success")
    end,

    help    = function()
        Message:Send("Check the Developer Console for more information.", "Info")
        warn(string.format([[
            Animation Changer [%s]

            Usage:

            /e replace [Position] [Emote]
            Ex: /e replace 3 Tree

            /e save -- Saves your current emote wheel.

            /e load -- Loads your save.

            /e help -- Lists all the commands and emotes.

            /e autoload [boolean] (true or false) -- will auto load your save every time you reset

            /e refresh -- refreshes emote wheel.
        ]], contact))

        table.foreach(choices, print)
    end,

    save    = function()
        if isfolder("emote_system") then
            writefile("emote_system/emote_saves.txt", json_encode(equipped_emotes))
        else
            makefolder("emote_system")
            writefile("emote_system/emote_saves.txt", json_encode(equipped_emotes))
            writefile("emote_system/autoload.txt", "true")
        end

        Message:Send("Saved current equipped emotes!", "Success")
    end,

    load    = function()
        equipped_emotes = json_decode(readfile("emote_system/emote_saves.txt"))

        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local Humanoid  = Character:FindFirstChildOfClass("Humanoid")

        if not Humanoid then
            return
        end

        Humanoid.HumanoidDescription:SetEquippedEmotes(equipped_emotes)

        Message:Send("Loaded last save!", "Success")
    end,

    autoload    = function(boolean)
        writefile('emote_system/autoload.txt', tostring(boolean))
        Message:Send("Set the setting 'Auto-Load' to ".. boolean, "Success")
    end,

    refresh      = function()
        character_added(LocalPlayer.Character)

        Message:Send("Refreshed!", "Success")
    end
}

-- chatted_connections
LocalPlayer.Chatted:Connect(function(message)
    local chat_arguments    = string_spl(message, " ")
    if chat_arguments[1] == "/e" then
        table.remove(chat_arguments, 1)

        local command       = commands[string.lower(chat_arguments[1])]
        table.remove(chat_arguments, 1)

        if command then
            command(unpack(chat_arguments))
        end
    end
end)

-- fix_chat
task.spawn(function()
    local metatable = getmetatable(require(game:GetService("Chat"):WaitForChild("ClientChatModules"):WaitForChild("CommandModules"):WaitForChild("Util")))

    check = hookfunction(metatable.SendSystemMessageToSelf, function(self, content, ...)
        if content == "You can't use that Emote." or content == "You can't use Emotes here." then return end
        
        return check(self, content, ...)
    end)
end)

-- add_connections
character_added(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(character_added)

-- announce_startup
warn("Lunaware Engine: Loaded Animation Editor")