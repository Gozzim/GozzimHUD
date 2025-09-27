-- Table to represent a Custom Modal Window and its associated functions
CustomModalWindowList = {}
CustomModalWindowCount = 0
CustomModalWindow = {}
CustomModalWindow.__index = CustomModalWindow

-- Set up the constructor call
setmetatable(CustomModalWindow, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

-- Don't touch it
function onCustomModalButtonOnClick(modalId, buttonId)
    local customModalWindow = CustomModalWindowList[modalId]
    if not customModalWindow then return end

    customModalWindow:onButtonClick(buttonId)
end

-- Don't touch it
function CustomModalWindow:onButtonClick(buttonId)
    if not self.onButtonClickCallback then return end

    self.onButtonClickCallback(buttonId)
end

--- Constructor for the Custom Modal Window class
-- @param caption the title of the modal window
-- @param description the description of the modal window
-- @return A new Custom Modal Window object
function CustomModalWindow.new(caption, description)
    local self = setmetatable({}, CustomModalWindow)
    -- The self.id works as an index, can start from 0
    self.id = customModalCreate()

    if caption then
        customModalSetCaption(self.id, caption)
    end

    if description then
        -- remove \n characters
        description = description:gsub("\n", "")
        if #description > 54 then
            description = description:sub(1, 54)
        end

        customModalSetDescription(self.id, description)
    end

    CustomModalWindowList[self.id] = self
    CustomModalWindowCount = CustomModalWindowCount + 1
    if CustomModalWindowCount == 1 then
        Game.registerEvent(Game.Events.CUSTOM_MODAL_WINDOW_BUTTON_CLICK, onCustomModalButtonOnClick)
    end
    return self
end

setmetatable(CustomModalWindow, {__call = function(_, ...) return CustomModalWindow.new(...) end})

--- Get the custom modal window's ID.
-- @return The custom modal window's ID
function CustomModalWindow:getId()
    return self.id
end

-- Set the modal window caption
function CustomModalWindow:setCaption(caption)
    customModalSetCaption(self.id, caption)
end

-- Set the modal window description
function CustomModalWindow:setDescription(description)
    customModalSetDescription(self.id, description)
end

-- Set custom modal button on click callback
function CustomModalWindow:setCallback(callback)
    self.onButtonClickCallback = callback
end

-- Add a button to the modal window
-- Note: the limit of buttons is 20
-- @returns The button id, this works as an index, can start from 0
function CustomModalWindow:addButton(buttonText)
    return customModalAddButton(self.id, buttonText)
end

-- Destroy the custom modal window
function CustomModalWindow:destroy()
    customModalDestroy(self.id)
    CustomModalWindowCount = CustomModalWindowCount - 1
    CustomModalWindowList[self.id] = nil
    if CustomModalWindowCount == 0 then
        Game.unregisterEvent(Game.Events.CUSTOM_MODAL_WINDOW_BUTTON_CLICK, onCustomModalButtonOnClick)
    end
    self = nil
end