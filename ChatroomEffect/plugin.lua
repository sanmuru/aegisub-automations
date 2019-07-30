local unicode = require("aegisub.unicode")
local regexutil = require("aegisub.re")
local util = require("aegisub.util")
local lfs = require("lfs")
require("chatroomeffect.util")

local plugin = {}

local layoutsdir = "automation\\include\\chatroomeffect\\layouts"
local layoutsrequirepath = "chatroomeffect.layouts"


local logicsdir = "automation\\include\\chatroomeffect\\logics"
local logicsrequirepath = "chatroomeffect.logics"
plugin.logics = {}
plugin.loadlayoutlogic = function(source)
	local layoutlogic
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
							layoutlogic = require(layoutsrequirepath.."."..filename) -- 加载布局插件。
						end,
						function(err)
							log_warning(string.format("加载布局插件失败：%s\n%s", err, debug.traceback()))
						end
					)
				end
			end
		end
	elseif type(source) == "table" then
		layoutlogic = source
	end

	xpcall(
		function()
			local loadinternal = function(layoutlogictype, layoutlogic)
				if plugin.logics[layoutlogictype] == nil then
					plugin.logics[layoutlogictype] = layoutlogic
				elseif plugin.logics[layoutlogictype] ~= layoutlogic then
					if plugin.logics[layoutlogictype].priority == layoutlogic.priority then
						error("插件优先级别冲突。")
					elseif plugin.logics[layoutlogictype].priority < layoutlogic.priority then
						plugin.logics[layoutlogictype] = layoutlogic
					end
				end
			end
			if type(layoutlogic.type) == "table" then
				for _, layoutlogictype in ipairs(layoutlogic.type) do
					loadinternal(layoutlogictype, layoutlogic)
				end
			elseif type(layoutlogic.type) == "string" then
				loadinternal(layoutlogic.type, layoutlogic)
			else error("无法识别布局插件的类型。")
			end
		end,
		function(err)
			log_warning(string.format("加载布局插件失败：%s\n%s", err, debug.traceback()))
		end
	)
end
for entry in lfs.dir(logicsdir) do
	if entry ~= '.' and entry ~= '..' then
		local path = logicsdir.."\\"..entry
		plugin.loadlayoutlogic(path)
	end
end

local shapesdir = "automation\\include\\chatroomeffect\\shapes"
local shapesrequirepath = "chatroomeffect.shapes"
plugin.shapes = {}
plugin.loadshapes = function(source)
	local layoutshape
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
							layoutshape = require(layoutsrequirepath.."."..filename) -- 加载图形。
						end,
						function(err)
							log_warning(string.format("加载布局插件失败：%s\n%s", err, debug.traceback()))
						end
					)
				end
			end
		end
	elseif type(source) == "table" then
		layoutshape = source
	end

	xpcall(
		function()
			local loadinternal = function(layoutshapetype, layoutshape)
				if plugin.shapes[layoutshapetype] == nil then
					plugin.shapes[layoutshapetype] = layoutshape
				elseif plugin.shapes[layoutshapetype] ~= layoutshape then
					if plugin.shapes[layoutshapetype].priority == layoutshape.priority then
						error("插件优先级别冲突。")
					elseif plugin.shapes[layoutshapetype].priority < layoutshape.priority then
						plugin.shapes[layoutshapetype] = layoutshape
					end
				end
			end
			if type(layoutshape.type) == "table" then
				for _, layoutshapetype in ipairs(layoutshape.type) do
					loadinternal(layoutshapetype, layoutshape)
				end
			elseif type(layoutshape.type) == "string" then
				loadinternal(layoutshape.type, layoutshape)
			else error("无法识别布局插件的类型。")
			end
		end,
		function(err)
			log_warning(string.format("加载布局插件失败：%s\n%s", err, debug.traceback()))
		end
	)
end
for entry in lfs.dir(shapesdir) do
	if entry ~= '.' and entry ~= '..' then
		local path = shapesdir.."\\"..entry
		plugin.loadshapes(path)
	end
end

return plugin