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

	local line
	if layouts[line.effect] ~= nil then
		local layout = layouts[line.effect]
		local minsize = measure_minsize(layout, { width = res_y, height = nil }, data)
		local result = do_layout(layout, 0, { x = 0, y = 0, width = minsize.width, height = minsize.height }, data)
	end
end

--[[ [Obsolete] 测算布局。
---- 参数： line, styles, layout, layer, rect, data
	line: 当前处理的行。
	styles: 已定义的所有样式。
	layout: 当前处理的布局。
	layer: 当前处理的布局的层数。 
	rect: 容纳布局的最大可用区域，布局应不超过这个范围。
	data: 一些必要的数据。
---- 返回： result, minsize
	result: 当前布局及所有子布局的table。
	minsize: 当前布局及所有子布局的最小需要尺寸。
--]]
local measure_layout = function(line, styles, layout, layer, rect, data)
	local meta = layoututil.parse_meta(layout, rect)
	
	-- 几种条件下布局因为超出显示范围而无意义。
	if meta.width <= 0 or meta.height <= 0 -- fill模式下计算得出的宽度和高度不大于零。
	--[[ or
		(horizontalalignment == "left" and margin.left >= size.width) or
		(horizontalalignment == "right" and margin.right >= size.width) or
		(verticalalignment == "top" and margin.top >= size.height) or
		(verticalalignment == "bottom" and margin.bottom >= size.height)
	--]] then
		return nil, { width = 0, height = 0 }
	end

	local result, minsize
	-- 规划可用空间范围，若宽度或高度为auto，则使用可用的最大值。
	local avaliablerect = {
		x = nil,
		y = nil,
		width = nil,
		height = nil
	}
	if width ~= nil then avaliablerect.width = width
	elseif rect.width == nil then avaliablerect.width = nil
	else avaliablerect.width = util.clamp(rect.width - margin.left - margin.right, minwidth, maxwidth)
	end
	if height ~= nil then avaliablerect.height = height
	elseif rect.height == nil then avaliablerect.height = nil
	else avaliablerect.height = height or util.clamp(rect.height - margin.top - margin.bottom, minheight, maxheight)
	end
	if avaliablerect.width == nil then avaliablerect.x = 0
	elseif horizontalalignment == "left" or avaliablerect.width == nil then
		avaliablerect.x = rect.x + margin.left
	elseif horizontalalignment == "center" then
		avaliablerect.x = rect.x + (rect.width - (avaliablerect.width - margin.left + margin.right)) / 2
	elseif horizontalalignment == "right" then
		avaliablerect.x = rect.x + rect.width - (avaliablerect.width + margin.right)
	end
	if avaliablerect.height == nil then avaliablerect.y = 0
	elseif verticalalignment == "top" or avaliablerect.height == nil then
		avaliablerect.y = rect.y + margin.top
	elseif verticalalignment == "center" then
		avaliablerect.y = rect.y + (rect.height - (avaliablerect.height - margin.top + margin.bottom)) / 2
	elseif verticalalignment == "bottom" then
		avaliablerect.y = rect.y + rect.height - (avaliablerect.height + margin.bottom)
	end
	
	if layout.layouttype == "flow" then -- 流式布局
		
	elseif layout.layouttype == "table" then -- 表式布局
		local tablelength_parse = function(length)
			if length == nil then
				return true, { type = "auto" }
			elseif tonumber(length) ~= nil then
				return true, { type = "pixel", value = tonumber(length) }
			elseif type(length) == "string" then
				if unicode.to_lower_case(length) == "auto" then
					return true, { type = "auto" }
				elseif regexutil.find("^\\s*(\\d*\\.\\d*|\\d+)\\s*\\*\\s*$", length) then
					return true, { type = "weight", value = tonumber(regexutil.match("\\d*\\.\\d*|\\d+", length)[1].str) }
				end
			elseif type(length) == "table" then
				if type(length.type) == "string" then
					if unicode.to_lower_case(length.type) == "auto" then
						return true, { type = "auto" }
					elseif unicode.to_lower_case(length.type) == "pixel" and tonumber(length.value) ~= nil then
						return true, { type = "pixel", value = tonumber(length.value) }
					elseif unicode.to_lower_case(length.type) == "weight" and tonumber(length.value) ~= nil then
						return true, { type = "weight", value = tonumber(length.value) }
					end
				end
			end
			
			return false
		end
		
		-- 计算所有行高和列宽。
		local rows, columns
		if layout.rows == nil then rows = {}
		elseif type(layout.rows) == "string" then
			if util.trim(layout.rows) == "" then
				rows = {}
			elseif regexutil.find("^\\s*(auto|(\\d*\\.\\d*|\\d+)\\*?)?(\\s*,\\s*(auto|(\\d*\\.\\d*|\\d+)\\*?)*\\s*$", layout.rows) then
				rows = {}
				regexresult = regexutil.find("(?:(^|,)\\s*)(auto|(\\d*\\.\\d*|\\d+)\\*?)(?:\\s*($|,))", layout.margin)
				for _, match in ipairs(regexresult) do
					local f, rowheight = tablelength_parse(row)
					if f then table.insert(rows, rowheight)
					else log_error("rows值的格式不正确。")
					end
				end
			else log_error("rows值的格式不正确。")
			end
		elseif type(layout.rows) == "table" then
			rows = {}
			for _, row in layout.rows do
				local f, rowheight = tablelength_parse(row)
				if f then table.insert(rows, rowheight)
				else log_error("rows值的格式不正确。")
				end
			end
		else log_error("rows值的格式不正确。")
		end
		if layout.columns == nil then columns = {}
		elseif type(layout.columns) == "string" then
			if util.trim(layout.columns) == "" then
				columns = {}
			elseif regexutil.find("^\\s*(auto|(\\d*\\.\\d*|\\d+)\\*?)?(\\s*,\\s*(auto|(\\d*\\.\\d*|\\d+)\\*?)*\\s*$", layout.columns) then
				columns = {}
				regexresult = regexutil.find("(?:(^|,)\\s*)(auto|(\\d*\\.\\d*|\\d+)\\*?)(?:\\s*($|,))", layout.margin)
				for _, match in ipairs(regexresult) do
					local f, columnheight = tablelength_parse(column)
					if f then table.insert(columns, columnheight)
					else log_error("columns值的格式不正确。")
					end
				end
			else log_error("columns值的格式不正确。")
			end
		elseif type(layout.columns) == "table" then
			columns = {}
			for _, column in layout.columns do
				local f, columnheight = tablelength_parse(column)
				if f then table.insert(columns, columnheight)
				else log_error("columns值的格式不正确。")
				end
			end
		else log_error("columns值的格式不正确。")
		end
		
		for _i, content in ipairs(layout) do
			local row, column, rowspan, columnspan
			row = tonumber(content["table$row"]) or 1
			column = tonumber(content["table$column"]) or 1
			rowspan = tonumber(content["table$rowspan"]) or 1
			columnspan = tonumber(content["table$columnspan"]) or 1
			
		end
	end
	
	if result.rect.width < minwidth then result.rect.width = minwidth end
	if result.rect.height < minheight then result.rect.height = minheight end
	result.clip = {
		rects = {},
		intersect = function(self, rect)
			local newrects = {}
			for _, r in ipairs(self.rects) do
				if r.x + r.width > rect.x and rect.x + rect.width > r.x and
					r.y + r.height > rect.y and rect.y + rect.height > r.y then
					local newrect = {
						x = math.max(r.x, rect.x),
						y = math.max(r.y, rect.y),
						width = math.min(r.x + r.width, rect.x + rect.width) - math.max(r.x, rect.x),
						height = math.min(r.y + r.height, rect.y + rect.height) - math.max(r.y, rect.y)
					}
					for index = #newrects, 1, -1 do
						local _r = newrects[index]
						if _r.x >= newrect.x and _r.x + _r.width <= newrect.x + newrect.width and
							_r.y >= newrect.y and _r.y + _r.height <= newrect.y + newrect.height then
							table.remove(newrects, index)
						end
					end
					table.insert(newrects, newrect)
				end
			end
			self.rects = newrects
		end,
		union = function(self, rect)
			local newrects = {}
			for index = 1, #self.rects do
				local _r = self.rects[index]
				if _r.x <= rect.x and _r.x + _r.width >= rect.x + rect.width and
					_r.y <= rect.y and _r.y + _r.height >= rect.y + rect.height then
					table.insert(newrects, _r)
				elseif _r.x > rect.x and _r.x + _r.width < rect.x + rect.width and
					_r.y > rect.y and _r.y + _r.height < rect.y + rect.height then
					table.insert(rect)
				else
					table.insert(newrects, _r)
					table.insert(rect)
				end
			end
			self.rects = newrects
		end
	}
	if (maxwidth ~= nil and result.rect.width > maxwidth) or
		(maxheight ~= nil and result.rect.height > maxheight) then
		local cliprect = {
			width = math.min(result.rect.width, maxwidth),
			height = math.min(result.rect.height, maxheight)
		}
		if horizontalalignment == "left" then cliprect.x = result.rect.x
		elseif horizontalalignment == "center" then cliprect.x = result.rect.x + (result.rect.width - cliprect.width) / 2
		elseif horizontalalignment == "right" then cliprect.x = result.rect.x + result.rect.width - cliprect.width
		end
		if verticalalignment == "top" then cliprect.y = result.rect.y
		elseif verticalalignment == "center" then cliprect.y = result.rect.y + (result.rect.height - cliprect.height) / 2
		elseif verticalalignment == "bottom" then cliprect.y = result.rect.y + result.rect.height - cliprect.height
		end
		result.clip:union(cliprect)
	end
	result.margin = margin
	result.layer = layer
	result.horizontalalignment = horizontalalignment
	result.verticalalignment = verticalalignment
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