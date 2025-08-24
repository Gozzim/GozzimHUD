-- Grand Master Oberon Auto-Responder for Zerobot

-- Define the handler function that will process talk events.
-- The parameters (authorName, text, etc.) are passed by the event system as seen in game.lua.
local function oberonTalkHandler(authorName, authorLevel, type, x, y, z, text, channelId)

    --if authorName == 'Grand Master Oberon' then

    if text:find('The world will suffer for its idle laziness!') then
        Game.talk('Are you ever going to fight or do you prefer talking!', Enums.TalkTypes.TALKTYPE_SAY)

    elseif text:find('People fall at my feet when they see me coming!') then
        Game.talk('Even before they smell your breath?', Enums.TalkTypes.TALKTYPE_SAY)

    elseif text:find("I will remove you from this plane of existence!") then
        Game.talk('Too bad you barely exist at all!', Enums.TalkTypes.TALKTYPE_SAY)

    elseif text:find("ULTAH SALID'AR, ESDO LO!") then
        Game.talk('SEHWO ASIMO, TOLIDO ESD', Enums.TalkTypes.TALKTYPE_SAY)

    elseif text:find('Dragons will soon rule this world, I am their herald!') then
        Game.talk('Excuse me but I still do not get the message!', Enums.TalkTypes.TALKTYPE_SAY)

    elseif text:find('I lead the most honourable and formidable following of knights!') then
        Game.talk('Then why are we fighting alone right now?', Enums.TalkTypes.TALKTYPE_SAY)

    elseif text:find('You appear like a worm among men!') then
        Game.talk('How appropriate, you look like something worms already got the better of!', Enums.TalkTypes.TALKTYPE_SAY)

    elseif text:find('This will be the end of mortal men!') then
        Game.talk('Then let me show you the concept of mortality before it!', Enums.TalkTypes.TALKTYPE_SAY)

    elseif text:find('The true virtues of chivalry are my belief!') then
        Game.talk('Dare strike up a Minnesang and you will receive your last accolade!', Enums.TalkTypes.TALKTYPE_SAY)
    end
    --end
end

-- Register our handler function to listen for the TALK event.
-- This tells the game engine to call oberonTalkHandler whenever a message appears in chat.
Game.registerEvent(Game.Events.TALK, oberonTalkHandler)

-- Prints a confirmation message in the Zerobot console when the script is loaded.
print('>> Corrected Oberon Auto-Responder has been loaded and is active.')
