-- Table to represent a Timer and its associated functions
Timer = {}
Timer.__index = Timer

-- Set up the constructor call for Timer
setmetatable(Timer, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

-- Table to keep track of all Timers
Timers = {
	timersRegistered = false, -- Flag to check if timers have been registered
	lastTimerIndex = nil,  -- Index of the last processed timer
	list = {}              -- List of all timers
}

--- Process all registered timers.
-- This function iterates through all registered timers, updating and executing them as necessary.
-- DO NOT RENAME THIS FUNCTION!
function processTimer()
	if #Timers.list > 0 then
		if not Timers.lastTimerIndex then
			Timers.lastTimerIndex = 1
		end

		local timer = Timers.list[Timers.lastTimerIndex]
		if not timer then
			Timers.lastTimerIndex = 1 -- in rare cases the index can be out of bounds, so we reset it here as a hot-fix
			return
		end

		-- if timer isn't active, we can skip it and recall processTimer
		if not timer._active then
			Timers.lastTimerIndex = Timers.lastTimerIndex + 1
			if Timers.lastTimerIndex > #Timers.list then
				Timers.lastTimerIndex = 1
				return
			end

			processTimer()
			return
		end

		if timer._active and timer._lastTrigger <= (os.clock() * 1000) then
			timer:run()
			timer:update(timer._delay)
		end

		Timers.lastTimerIndex = Timers.lastTimerIndex + 1
		if Timers.lastTimerIndex > #Timers.list then
			Timers.lastTimerIndex = 1
			return
		end

		processTimer()
	end
end

--- Destroy a timer by name.
-- @param name (string) - The name of the timer to destroy.
function destroyTimer(name)
	for i, timer in ipairs(Timers.list) do
		if timer:name() == name then
			timer:stop()
			table.remove(Timers.list, i)
			break
		end
	end

	if #Timers.list == 0 then
		timerEnabled(false)
	end
end

--- Constructor for the Timer class.
-- @param name (string) - The name of the timer.
-- @param timerFunction (function) - The function to execute when the timer triggers.
-- @param timeDelay (number) - The delay between timer triggers, in milliseconds.
-- @param autoStart (boolean) - Whether to start the timer automatically.
-- @return A new Timer object.
function Timer.new(name, timerFunction, timeDelay, autoStart)
	local timer
	autoStart = autoStart ~= false and true or false

	if timerFunction then
		destroyTimer(name)
		timer = setmetatable({}, Timer)

		timer._name = name
		timer._function = timerFunction
		timer._active = autoStart
		timer._delay = timeDelay and timeDelay or 100 -- default 100ms
		timer._lastTrigger = 0

		table.insert(Timers.list, timer)
	else
		for i, timer in ipairs(Timers.list) do
			if timer:name() == name then
				timer = timer
				break
			end
		end
	end

	if #Timers.list == 1 then
		timerEnabled(true)
	end

	return timer
end

--- Run the timer's function. No need to use it directly, create timer by using new constructor
-- @return The result of the timer's function.
function Timer:run()
	self = type(self) == 'table' and self or Timer.new(self)
	if type(self._function) == 'string' then
		self._function = _G[self._function]
	end
	return self:_function()
end

--- Get the timer's name.
-- @return The name of the timer.
function Timer:name()
	return self._name
end

--- Start the timer.
function Timer:start()
	self = type(self) == 'table' and self or Timer.new(self)
	self._active = true
	self._lastTrigger = 0
end

--- Update the timer's last trigger time. No need to use it directly.
-- @param delayTime (number) - The new delay time for the timer, in milliseconds.
function Timer:update(delayTime)
	self = type(self) == 'table' and self or Timer.new(self)
	self._lastTrigger = (os.clock() * 1000) + delayTime
end

--- Stop the timer.
function Timer:stop()
	self = type(self) == 'table' and self or Timer.new(self)
	self._active = false
end

---- Check if timer is active
function Timer:isActive()
	self = type(self) == 'table' and self or Timer.new(self)
	return self._active
end
