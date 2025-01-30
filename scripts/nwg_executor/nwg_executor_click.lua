for line in io.lines("/home/vince/Scripts/nwg_executor/nwg_executor_value") do
	if line == "Updates are available!" then
		os.execute('kitty sh -c "eos-update && read -p "Updates have finished..."')
		os.execute("lua /home/vince/Scripts/nwg_executor/nwg_executor_update.lua")
		return
	elseif line == "Up To Date" then
		os.execute("lua /home/vince/Scripts/nwg_executor/nwg_executor_update.lua")
		return
	end
end
