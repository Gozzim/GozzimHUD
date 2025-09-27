-- Table to represent a HUD and its associated functions
HUDList = {}
HUDCount = 0
HUD = {}
HUD.__index = HUD

-- Set up the constructor call
setmetatable(HUD, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

-- Don't touch it
function onHudClick(id)
    local hudItem = HUDList[id]
    if not hudItem then return end

    hudItem:onClick()
end

-- Don't touch it
function HUD:onClick()
    if self.destroyed then return end
    if not self.callback then return end

    self.callback()
end

--- Constructor for the HUD class
-- @param x coordinate of the game window on the x-axis
-- @param y coordinate of the game window on the y-axis
-- @param value the text or itemid to draw on the screen
-- @param newFeatures boolean to enable/disable new features
-- @return A new HUD object
-- @important Please, don't use HUDItem functions in HUDText element and vice-versa
function HUD.new(x, y, value, newFeatures)
    local self = setmetatable({}, HUD)
    self.newFeatures = newFeatures
    -- The self.id works as an index, can start from 0
	if (type(value) == 'number') then
		self.id = hudItemCreate(newFeatures or false)
        self.isItem = true
        self:setItemId(value)
	else
		self.id = hudTextCreate(newFeatures or false)
        self.isText = true
        self:setText(value)
	end

    self:setPos(x, y)
    HUDList[self.id] = self
    HUDCount = HUDCount + 1
    if HUDCount == 1 then
        Game.registerEvent(Game.Events.HUD_CLICK, onHudClick)
    end
    return self
end

setmetatable(HUD, {__call = function(_, ...) return HUD.new(...) end})

function HUD.newSpellIcon(x, y, spellId, newFeatures)
    local self = setmetatable({}, HUD)

    self.newFeatures = newFeatures
    self.id = hudSpellIconCreate(newFeatures or false)
    self.isSpellIcon = true
    self:setSpellIconId(spellId)
    self:setPos(x, y)

    HUDList[self.id] = self
    HUDCount = HUDCount + 1
    if HUDCount == 1 then
        Game.registerEvent(Game.Events.HUD_CLICK, onHudClick)
    end
    return self
end

-- newOutfit
function HUD.newOutfit(x, y, outfitId, newFeatures)
    local self = setmetatable({}, HUD)

    self.newFeatures = newFeatures
    self.id = hudOutfitCreate(newFeatures or false)
    self.isOutfit = true
    self:setOutfitId(outfitId)
    self:setPos(x, y)

    HUDList[self.id] = self
    HUDCount = HUDCount + 1
    if HUDCount == 1 then
        Game.registerEvent(Game.Events.HUD_CLICK, onHudClick)
    end
    return self
end

--- Get the hud's ID.
-- @return The hud's ID
function HUD:getId()
    return self.id
end

-- Get current hud position
-- Note: this function will return the draw position X, Y on screen, shouldn't be used directly for setPos function.
-- Also this function can return x:0,y:0 until the first draw since it return the draw position on game screen.
-- @return The hud's drawn position, as table {x=0, y=0}
function HUD:getPos()
    if self.destroyed then return end

    return hudGetPos(self.id)
end

-- Set current hud position
-- Note: if you are using alignments, this function will be used as the margin offsets.
-- Also, when you set position of a HUD element it will reset the mouse dragging offsets to 0,0.
function HUD:setPos(x, y)
    if self.destroyed then return end

    hudSetPos(self.id, x, y)
end

-- Get current margins used on alignemnts
-- Can be used only if newFeatures is enabled, also remember the margins are set by setPos function if you are using alignments.
-- @return The hud's margins, as table {x=0, y=0}
function HUD:getMargins()
    if self.destroyed then return end
    if not self.newFeatures then return end

    return hudGetMargins(self.id)
end

-- Hide hud
function HUD:hide()
    if self.destroyed then return end

    hudSetVisible(self.id, false)
end

-- Show hud
function HUD:show()
    if self.destroyed then return end

    hudSetVisible(self.id, true)
end

-- Set draggable state of specific hud
function HUD:setDraggable(draggable)
    if self.destroyed then return end

    hudSetDraggable(self.id, draggable)
end

-- Set hud text, only works if hud is a text
function HUD:setText(text)
    if self.destroyed then return end
    if self.isItem then return end

    hudTextSetText(self.id, text)
end

-- Set hud text horizontal alignment. Default is Enums.HorizontalAlign.None
-- Can be used only if newFeatures is enabled
-- Remember: when using any horizontal alignment type, your X position will be the margin offset.
function HUD:setHorizontalAlignment(alignment)
    if self.destroyed then return end
    if not self.newFeatures then return end

    hudSetHorizontalAlignment(self.id, alignment)
end

-- Set hud text vertical alignment. Default is Enums.VerticalAlign.None
-- Can be used only if newFeatures is enabled
-- Remember: when using any vertical alignment type, your Y position will be the margin offset.
function HUD:setVerticalAlignment(alignment)
    if self.destroyed then return end
    if not self.newFeatures then return end

    hudSetVerticalAlignment(self.id, alignment)
end

-- Set hud text color
function HUD:setColor(r, g, b)
    if self.destroyed then return end
    if self.isItem then return end

    hudTextSetColor(self.id, r, g, b)
end

-- Set hud text font size. Default is 8.25
-- Can be used only if newFeatures is enabled
function HUD:setFontSize(fontSize)
    if self.destroyed then return end
    if self.isItem then return end

    hudTextSetFontSize(self.id, fontSize)
end

-- Set hud item id
function HUD:setItemId(id)
    if self.destroyed then return end
    if not self.isItem then return end

    hudItemSetItemId(self.id, id)
end

-- Set hud spell icon index
function HUD:setSpellIconId(id)
    if self.destroyed then return end
    if not self.isSpellIcon or not self.newFeatures then return end

    hudSetSpellIconId(self.id, id)
end

-- Set outfit id (the outfit id needs to exist on the client). Returns false if the outfit id is 0, nil if hud doesn't exists anymore.
function HUD:setOutfitId(id)
    if self.destroyed then return end
    if not self.isOutfit or not self.newFeatures then return end

    hudOutfitSetOutfitId(self.id, id)
end

-- Set outfit addons (0, 1, 2 or 3 for full)
function HUD:setOutfitAddons(addons)
    if self.destroyed then return end
    if not self.isOutfit or not self.newFeatures then return end

    hudOutfitSetAddons(self.id, addons)
end

-- Set outfit colors (the colors should be from 0 to 132)
function HUD:setOutfitColors(head, body, legs, feet)
    if self.destroyed then return end
    if not self.isOutfit or not self.newFeatures then return end

    hudOutfitSetColors(self.id, head, body, legs, feet)
end

-- Set outfit direction (0, 1, 2, or 3, for north, east, south, west, can be based on Enums.Directions)
function HUD:setOutfitDirection(direction)
    if self.destroyed then return end
    if not self.isOutfit or not self.newFeatures then return end

    hudOutfitSetDirection(self.id, direction)
end

-- Set outfit moving (false for idle, true for walking)
function HUD:setOutfitMoving(moving)
    if self.destroyed then return end
    if not self.isOutfit or not self.newFeatures then return end

    hudOutfitSetMoving(self.id, moving)
end

-- Set hud item size. The limit of size for items is based on their sprite. 
-- Example: gold coin size is 32x32, so you can't pass these values.
-- If you need to scale more the size, you can use HUD:setScale(value) function
function HUD:setSize(width, height)
    if self.destroyed then return end

    hudSetSize(self.id, width, height)
end

-- Set hud item/spell/outfit scale. The value is a float number, where 1.0 is the default size.
-- Can be used only if newFeatures is enabled
function HUD:setScale(value)
    if self.destroyed then return end
    if (not self.isItem and not self.isSpellIcon and not self.isOutfit) or not self.newFeatures then return end

    hudSetScale(self.id, value)
end

-- Set hud spell icon opacity. The value is a float number, where 1.0 is the default opacity and 0.0 is fully transparent.
-- Only support item and spell hud.
-- Can be used only if newFeatures is enabled
function HUD:setOpacity(value)
    if self.destroyed then return end
    if not self.newFeatures then return end

    hudSetOpacity(self.id, value)
end

-- Set hud on click callback
function HUD:setCallback(callback)
    if self.destroyed then return end

    self.callback = callback
end

-- Destroy the hud
function HUD:destroy()
    if self.destroyed then return end

    hudDestroy(self.id)
    HUDCount = HUDCount - 1
    HUDList[self.id] = nil
    if HUDCount == 0 then
        Game.unregisterEvent(Game.Events.HUD_CLICK, onHudClick)
    end

    self.destroyed = true
end