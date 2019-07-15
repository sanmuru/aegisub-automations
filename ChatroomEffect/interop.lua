-- Copyright (c) 2019, Sam Lu

unicode = require("aegisub.unicode")
regexutil = require("aegisub.re")
util = require("aegisub.util")
lfs = require("lfs")

interop_version = "0.1.20190714"

local toolsdir = "automation\\include\\chatroomeffect\\tools"
local tmpdir = toolsdir.."\\TMP"
local interop = {}

interop.createtmpdir = function()
	lfs.mkdir(tmpdir)
end

interop.deletetmpdir = function()
	return os.execute("rd /s /q "..tmpdir)
end

interop.execute = function(tool, ...)
    if type(tool) ~= string then
        error(string.format("bad argument #1 to 'execute' (string expected, got %s)", type(tool)))
    end

    local cmdline = toolsdir.."\\"..tool
    for i = 1, select("#", ...) do
        cmdline = cmdline.." "
        local arg = select(i, ...)
        if type(arg) == "boolean" or
            type(arg) == "number" then
            arg = tostring(arg)
        elseif type(arg) == "string" then
            if regexutil.find("\\s", arg) then
                arg = "\""..arg.."\""
            end
        else arg = ""
        end
    end

    local result = io.popen(cmdline, "r")
    if result == nil then
        error("命令行执行失败。")
    end

    local lines = {}
    for line in result:lines() do
        table.insert(lines, line)
    end
    result:close()

    return lines
end

local imageinfobuffer = {}
interop.image = {}
interop.image.getinfo = function(...)
	local results = {}
	local unknownlist = {}

	for index = 1, select("#", ...) do
		local path = select(index, ...)
		if type(path) ~= string then
			error(string.format("bad argument #%d to 'getinfo' (string expected, got %s)", index, type(path)))
		end
		
		local file = io.open(path, "r")
		if file == nil then
			error(string.format("bad argument #%d to 'getinfo' (No such file or directory: '%s')", index, path))
		else file.close()
		end

		if result[path] == nil then
			if imageinfobuffer[path] ~= nil then
				result[path] = imageinfobuffer[path]
			elseif results[unicode.to_lower_case(path)] == nil then
				if imageinfobuffer[unicode.to_lower_case(path)] ~= nil then
					result[path] = imageinfobuffer[unicode.to_lower_case(path)]
				else
					table.insert(unknownlist, path)
				end
			else
				results[path] = results[unicode.to_lower_case(path)]
			end
		end
	end

	if #unknownlist ~= 0 then
		local tmpfilepath = tmpfilepath..os.tmpname()
		local file = io.open(tmpfilepath, "w")
		if file == nil then error("创建临时文件失败。") end
		for _, unknown in ipairs(unknownlist) do
			file:write(unknown)
			file:write("\\r\\n")
		end
	
		local errorstate, resultlines = xpacall(
			funtcion()
				return interop.execute("imageinfo", "@"..tmpfilepath)
			end,
			function(err)
				os.remove(tmpfilepath)
				print(debug.traceback())
			end
		)
		if not errorstate then error("error ocured in 'execute'") end
		os.remove(tmpfilepath)

		local info = {}
		for _, resultline in resultlines do
			if util.trim(resultline) == "" then
				result[path] = info
				imageinfobuffer[path] = info
				info = {}
			else
				local regexresult = regexutil.match("^([^:]+):\\s*(.*)\\s*$", resultline)
				local key, value = regexresult[2].str, regexresult[3].str
				
				if key == "width" or key == "height" then
					info[key] = tonumber(value)
				else
					info[key] = value
				end
			end
		end
		if info ~= nil then
			result[path] = info
			imageinfobuffer[path] = info
			info = nil
		end
	end

	return results
end

return interop