-- Copyright (c) 2019, Sam Lu

include("karaskel.lua")
local regexutil = require("aegisub.re")
local util = require("aegisub.util")
local interop = require("chatroomeffect.interop")
local layoututil = require("chatroomeffect.layoututil")
local plugin = require("chatroomeffect.plugin")
require("chatroomeffect.util")

script_name = "生成聊天室特效字幕"
script_description = "将原有的文本转化为聊天室特效字幕。"
script_author = "Sam Lu"
script_version = "0.1.20190714"

local process_main = function(subtitles, selection)
	local lines = {}
	if selectedlines then
		for i = 1, #selection do table.insert(lines, subtitles[selection[i]]) end
	else
		for i = 1, #subtitles do table.insert(lines, subtitles[i]) end
	end

	preprocess_layout()
	local meta = karaskel.collect_head(subtitles, false)
	local res_x, res_y = meta.res_x, meta.res_y
	if res_x == nil or res_y == nil then
		res_x, res_y = aegisub.video_size()
		if res_x == nil or res_y == nil then
			log_error("无法获取显示范围的宽度和高度。")
		end
	end

	local buffer = {}
	local timeline = {}
	timeline.n = 0
	for _, line in ipairs(lines) do
		if layouts[line.effect] ~= nil then
			local layout = layouts[line.effect]
			local minsize = layoututil.measure_minsize(layout, { width = res_y, height = nil }, data)
			local result = layoututil.do_layout(layout, 0, { x = 0, y = position, width = res_y, height = minsize.height }, data)

			timeline.n = timeline.n + 1
			timeline[result] = timeline.n
			table.insert(timeline, result)
			table.insert(buffer, { line = line, layoutresult = result }
		end
	end
	for _, li in ipairs(buffer) do
		local newlines = layoututil.generate_subtitles(li.line, li.layoutresult, timeline, animations)

		subtitles.append(newlines)
	end

	aegisub.set_undo_point("聊天室特效字幕应用完成。")
end



aegisub.register_macro(script_name, script_description, process_main)