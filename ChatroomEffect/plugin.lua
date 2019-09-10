local unicode = require("aegisub.unicode")
local regexutil = require("aegisub.re")
local util = require("aegisub.util")
local lfs = require("lfs")
require("chatroomeffect.util")

local plugin = {}

local createplugintype = function(plugintype, directoryname)
	if type(plugintype) ~= "string" then error(string.format("bad argument #1 to 'createplugintype' (string expected, got %s)", type(plugintype))) end
	if type(directoryname) ~= "string" then error(string.format("bad argument #2 to 'createplugintype' (string expected, got %s)", type(directoryname))) end
	
	local newplugintype = {}

	newplugintype.loaddirectory = "automation\\include\\chatroomeffect\\"..directoryname
	newplugintype.requirepath = "chatroomeffect.\\"..directoryname
	newplugintype.load = function(self, source)
		local p
		if type(source) == "string" then
			local attr = lfs.attributes(path)
			assert(type(attr) == "table") -- 如果获取不到属性表则报错
	
			if attr.mode == "file" then
				local regexresult = regexutil.match(".*([^\\\\\\/\\.]+)(\\.[^\\\\\\/\\.]+)", source)
				if regexresult then
					local filename, fileextension = regexresult[2].str, regexresult[3].str
					if unicode.to_lower_case(fileextension) == ".lua" or unicode.to_lower_case(fileextension) == ".moon" then
						xpcall(
							function()
								p = dofile(self.requirepath.."."..filename) -- 加载文件。
							end,
							function(err)
								log_warning(string.format("加载布局插件失败：%s\n%s", err, debug.traceback()))
							end
						)
					end
				end
			end
		elseif type(source) == "table" then
			p = source
		end

		xpcall(
			function()
				local loadinternal = function(ptype)
					if plugin[plugintype][ptype] == nil then
						plugin[plugintype][ptype] = p
					elseif plugin[plugintype][ptype] ~= p then
						if plugin[plugintype][ptype].priority == p.priority then
							error("插件优先级别冲突。")
						elseif plugin[plugintype][ptype].priority < p.priority then
							plugin[plugintype][ptype] = p
						end
					end
				end
				if type(p.type) == "table" then
					for _, ptype in ipairs(p.type) do
						loadinternal(ptype)
					end
				elseif type(p.type) == "string" then
					loadinternal(p.type)
				else error("无法识别布局插件的类型。")
				end
			end,
			function(err)
				log_warning(string.format("加载布局插件失败：%s\n%s", err, debug.traceback()))
			end
		)
	end

	setmetatable(newplugintype, {
		__existedkeys = (function(self)
			local t = {}
			for k, v in pairs(self) do
				table.insert(t, k)
			end

			return t
		end)(newplugintype),
		__newindex = function(self, key, value)
			local isexist = false
			for i, k in ipairs(self.__existedkeys) do
				if key == k then
					isexist = true
					break
				end
			end
			
			if not isexist then self[key] = value end
		end
	})

	plugin[plugintype] = newplugintype
	return newplugintype
end
local preloadplugintype = function(plugintype)
	for entry in lfs.dir(plugin[plugintype].loaddirectory) do
		if entry ~= '.' and entry ~= '..' then
			local path = plugin[plugintype].loaddirectory.."\\"..entry
			plugin[plugintype].load(path)
		end
	end
end

--[[ plugin.layout ]]
createplugintype("layout", "layouts")
preloadplugintype("layout")

--[[ plugin.layoutlogic ]]
createplugintype("layoutlogic", "logics")
preloadplugintype("layoutlogic")

--[[ plugin.actor ]]
createplugintype("actor", "actors")
preloadplugintype("actor")

--[[ plugin.shape ]]
createplugintype("shape", "shapes")
preloadplugintype("shape")

--[[ plugin.animation ]]
createplugintype("animation", "animations")
preloadplugintype("animation")

return plugin