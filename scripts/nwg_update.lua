Val, _ = os.execute("checkupdates")

if Val then
	print("/usr/share/pixmaps/nwg-update-available.svg")
	print("Updates Available!")
else
	print("/usr/share/pixmaps/nwg-update-noupdate.svg")
	print("Up To Date")
end
