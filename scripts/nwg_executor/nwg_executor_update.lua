local sleepTime = 900
local file = "/home/vince/Scripts/nwg_executor/nwg_executor_value"

local function writeToFile(valueToWrite)
	io.output(file)
	io.write(valueToWrite)
	io.close()
end

while true do
	writeToFile("/usr/share/pixmaps/nwg-update-checking.svg\nChecking for updates...")

	local val, _ = os.execute("checkupdates")
	if val then
		writeToFile("/usr/share/pixmaps/nwg-update-available.svg\nUpdates are available!")

		os.execute("play /home/vince/Music/sounds/boot.ogg")
	else
		writeToFile("/usr/share/pixmaps/nwg-update-noupdate.svg\nUp To Date")
	end

	if #arg > 0 and arg[1] == "--const" then
		os.execute("sleep " .. sleepTime)
	else
		return
	end
end
