for line in io.lines("/home/vince/Scripts/nwg_executor/nwg_executor_value") do
	if line == "Updates are available!" then
		local subS = "'Updates have finished...'"
		os.execute('kitty sh -c "eos-update && read -p ' .. subS .. '"')
		os.execute("lua /home/vince/Scripts/nwg_executor/nwg_executor_update.lua")
		return
	elseif line == "Up To Date" then
		os.execute("lua /home/vince/Scripts/nwg_executor/nwg_executor_update.lua")
		return
	end
	print(line)
end
