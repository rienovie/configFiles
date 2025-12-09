local export = {}

function export.run(cmd)
	local h = io.popen(cmd .. " 2>&1", "r")
	if not h then
		return {
			ok = false,
			exit = 1,
			output = "Could not open pipe",
		}
	end
	local out = h:read("*a")
	local ok, _, code = h:close()
	return {
		ok = ok,
		exit = code,
		output = out,
	}
end

function export.scanDir(dir, hidden)
	local files = {}
	local cmd = "ls -1 " .. (hidden and "-a " or "") .. dir
	for file in io.popen(cmd):lines() do
		if file:sub(1, 1) == "." or file:sub(1, 1) == ".." then
			goto continue
		end
		table.insert(files, file)
		::continue::
	end
	return files
end

function export.printTable(t)
	print("Table:")
	for k, v in pairs(t) do
		print("  " .. k .. ": " .. v)
	end
end

return export
