-- Copyright (c) 2019, Sam Lu

include("karaskel.lua")
local regexutil = require("aegisub.re")
local util = require("aegisub.util")
local interop = require("chatroomeffect.interop")
local layoututil = require("chatroomeffect.layoututil")
local plugin = require("chatroomeffect.plugin")

script_name = "生成聊天室特效字幕"
script_description = "将原有的文本转化为聊天室特效字幕。"
script_author = "Sam Lu"
script_version = "0.1.20190714"

log_fatal = function(msg, ...) aegisub.log(0, msg, ...) end
log_error = function(msg, ...) aegisub.log(1, msg, ...) end
log_warning = function(msg, ...) aegisub.log(2, msg, ...) end
log_hint = function(msg, ...) aegisub.log(3, msg, ...) end
log_debug = function(msg, ...) aegisub.log(4, msg, ...) end
log_trace = function(msg, ...) aegisub.log(5, msg, ...) end

local process_main = function(subtitles, selection)
	local lines = {}
	if selectedlines then
		for i = 1, #selection do table.insert(lines, subtitles[selection[i]]) end
	else
		for i = 1, #subtitles do table.insert(lines, subtitles[i]) end
	end

	preprocess_layout()
	local meta = karaskel.collect_head(subtitles, generate_furigana)
	local res_x, res_y = meta.res_x, meta.res_y
	if res_x == nil or res_y == nil then
		res_x, res_y = aegisub.video_size()
		if res_x == nil or res_y == nil then
			log_error("无法获取显示范围的宽度和高度。")
		end
	end

	local position = 0
	for _, line in ipairs(line) do
		if layouts[line.effect] ~= nil then
			local layout = layouts[line.effect]
			local minsize = layoututil.measure_minsize(layout, { width = res_y, height = nil }, data)
			local result = layoututil.do_layout(layout, 0, { x = 0, y = position, width = res_y, height = minsize.height }, data)

			result.position = position
			position = position + result.rect.height
		end
	end
end

local style_parse = function(styles, style, paramname)
	if type(style) == string then
		local existstyle = styles[style]
		if existstyle == nil then log_error("未定义名为\""..style.."\"的样式。") end
		return existstyle
	elseif type(style) == "table" then
		newstyle = util.copy(style)
		newstyle.override = nil -- 清除继承信息。
		if newstyle.override ~= nil then
			-- 获取继承树上层样式节点。
			local override = style_parse(newstyle.override, "override")
			-- 检查上层节点的每个键。
			for key, value in pairs(override) do
				if key ~= "override" then -- 不继承override键。
					newstyle[key] = newstyle[key] or override[key] -- 进行值的继承。
				end
			end
		end
		return newstyle
	else log_error((paramname or "style").."值的格式不正确。")
	end
end



aegisub.register_macro(script_name, script_description, process_main)