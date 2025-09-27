-- Table to represent sound functionalities
Sound = {}

--- Plays a .wav audio file.
-- This function is a wrapper around the external function soundPlay.
-- It allows the playing of a .wav audio file specified by the file path argument.
-- @param filePath (string) - The path to the .wav audio file that should be played.
-- @param isDefaultSound (bool) - If is true, the function will consider the filePath as a file name inside Documents/ZeroBot/Scripts/sounds directory.
-- @return (boolean) Returns true if the audio file is played successfully, false otherwise. If isDefaultSound is true, this function can return false if sound or directory doesn't exists.
function Sound.play(filePath, isDefaultSound)
    return soundPlay(filePath, isDefaultSound and isDefaultSound or false)
end
