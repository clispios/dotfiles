local module = {}
function module.getSystemInfo()
	local systemInfo = {}

	-- Detect operating system
	local osName
	if package.config:sub(1, 1) == "\\" then
		osName = "Windows"
	else
		-- Try to get more specific Unix-like OS information
		local f = io.popen("uname -s")
		if f then
			osName = f:read("*a"):gsub("%s+", "")
			f:close()
		else
			osName = "Unix-like" -- Fallback if uname is not available
		end
	end
	systemInfo.os = osName

	-- Get hostname
	local hostname
	if osName == "Windows" then
		local f = io.popen("hostname")
		if f then
			hostname = f:read("*a"):gsub("%s+", "")
			f:close()
		end
	else
		-- For Unix-like systems, try multiple methods
		local methods = {
			"hostname",
			"cat /etc/hostname",
			"uname -n",
		}

		for _, cmd in ipairs(methods) do
			local f = io.popen(cmd)
			if f then
				hostname = f:read("*a"):gsub("%s+", "")
				f:close()
				if hostname and hostname ~= "" then
					break
				end
			end
		end
	end
	systemInfo.hostname = hostname or "Unknown"

	return systemInfo
end

return module
