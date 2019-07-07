-- Copyright (c) 2019, Sam Lu

include("karaskel.lua")
regexutil = require("aegisub.re")
util = require("aegisub.util")

script_name = "生成聊天室特效字幕"
script_description = "将原有的文本转化为聊天室特效字幕。"
script_author = "Sam Lu"
script_version = "0.1.20190317"

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

	do_layout(lines, actors, layouts)
end

local do_layout = function(lines, actors, layouts)
	local xres, yres
	meta = karaskel.collect_head(subtitles, generate_furigana)
	if meta.res_x == nil or meta.res_y == nil then
		xres, yres = aegisub.video_size()
		if xres == nil or yres == nil then
			aegisub.log()

		end
	end

	local line
	if layouts[line.effect] ~= nil then
		local layout = layouts[line.effect]
		if layout.layer == nil then layout.layer = 0 end
	end
end

--[[ 测算布局
---- 参数：line, styles, layout, layer, rect, data
	 line: 当前处理的行。
	 styles: 已定义的所有样式。
	 layout: 当前处理的布局。
	 layer: 当前处理的布局的层数。
	 rect: 容纳布局的最大可用区域，布局应不超过这个范围。
	 data: 一些必要的数据。
---- 返回：result, minsize
	 result: 当前布局及所有子布局的table。
	 minsize: 当前布局及所有子布局的最小需要尺寸。
---- ]]--
local measure_layout = function(line, styles, layout, layer, rect, data)
	-- 计算margin。
	local margin
	if layout.margin == nil then margin = { left = 0, right = 0, top = 0, bottom = 0 }
	elseif tonumber(layout.margin) ~= nil then margin = { left = tonumber(layout.margin), right = tonumber(layout.margin), top = tonumber(layout.margin), bottom = tonumber(layout.margin) }
	elseif type(layout.margin) == "string" and regexutil.find("\\s*,\\s*(\\d*\\.\\d*||\\d+)(\\s*(\\d*\\.\\d*||\\d+)){2,4}\\s*", layout.margin) then
		regexresult = regexutil.find("(?:(^|,)\\s*)\\d*\\.\\d*||\\d+(?:\\s*($|,))", layout.margin)
		if #regexresult.margin == 2 then
			margin = {
				left = tonumber(regexresult[1]),
				right = tonumber(regexresult[1]),
				top = tonumber(regexresult[2]),
				bottom = tonumber(regexresult[2])
			}
		elseif #regexresult.margin == 4 then
			margin = {
				left = tonumber(regexresult[1]),
				right = tonumber(regexresult[2]),
				top = tonumber(regexresult[3]),
				bottom = tonumber(regexresult[4])
			}
		else log_error("margin值的格式不正确。")
		end
	elseif type(layout.margin) == "table" then
		if layout.margin.left or layout.margin.right or layout.margin.top or layout.margin.bottom then
			margin = {
				left = layout.margin.left or 0,
				right = layout.margin.right or 0,
				top = layout.margin.top or 0,
				bottom = layout.margin.bottom or 0
			}
		elseif #layout.margin == 2 then
			margin = {
				left = layout.margin[1],
				right = layout.margin[1],
				top = layout.margin[2],
				bottom = layout.margin[2]
			}
		elseif #layout.margin == 4 then
			margin = {
				left = layout.margin[1],
				right = layout.margin[2],
				top = layout.margin[3],
				bottom = layout.margin[4]
			}
		else log_error("margin值的格式不正确。")
		end
	else samlu.log.error("margin值的格式不正确。")
	end
	
	-- 计算宽度和高度的最小值和最大值。
	local minwidth, maxwidth, minheight, maxheight
	if layout.minwidth == nil then minwidth = 0
	elseif tonumber(layout.minwidth) ~= nil then
		minwidth = tonumber(layout.minwidth)
		if minwidth < 0 then log_error("minwidth值不应小于零。") end
	else samlu.log.error("minwidth值的格式不正确。")
	end
	if layout.maxwidth == nil then ;
	elseif tonumber(layout.maxwidth) ~= nil then
		maxwidth = tonumber(layout.maxwidth)
		if maxwidth < minwidth then log_error("maxwidth值不应小于minwidth。") end
	else samlu.log.error("minwidth值的格式不正确。")
	end
	if layout.minheight == nil then minheight = 0
	elseif tonumber(layout.minheight) ~= nil then
		minheight = tonumber(layout.minheight)
		if minheight < 0 then log_error("minheight值不应小于零。") end
	else samlu.log.error("minheight值的格式不正确。")
	end
	if layout.maxheight == nil then ;
	elseif tonumber(layout.maxheight) ~= nil then
		maxheight = tonumber(layout.maxheight)
		if maxheight < minheight then log_error("maxheight值不应小于minheight。") end
	else samlu.log.error("minheight值的格式不正确。")
	end
	
	-- 计算宽度和高度。
	local width, height
	if tonumber(layout.width) == nil then -- 非数字类型值
		if unicode.to_lower_case(layout.width) == "fill" then width = math.max(0, rect.width - margin.left - margin.right) -- 填充
		elseif unicode.to_lower_case(layout.width) ~= "auto" then log_error("width值应为数值、fill或auto。")
		--else -- 自动
		end
	else -- 数字类型值
		if type(layout.width) == "number" then width = layout.width
		else width = tonumber(layout.width)
		end
		if width < 0 then log_error("width值不应小于零。") end
	end
	if width < minwidth then width = minwidth
	elseif maxwidth ~= nil and width > maxwidth then width = maxwidth
	end
	if tonumber(layout.height) == nil then -- 非数字类型值
		if unicode.to_lower_case(layout.height) == "fill" then height = math.max(0, rect.height - margin.top - margint.bottom) -- 填充
		elseif unicode.to_lower_case(layout.height) ~= "auto" then log_error("height值应为数值、fill或auto。")
		--else -- 自动
		end
	else -- 数字类型值
		if type(layout.height) == "number" then height = layout.height
		else height = tonumber(layout.height)
		end
		if height < 0 then log_error("height值不应小于零。") end
	end
	if height < minheight then height = minheight
	elseif maxheight ~= nil and height > maxheight then height = maxheight
	end
	-- 若宽度或高度为auto，具体数值需要根据不同布局分别计算得出，故此时为nil。
	
	-- 计算横向和纵向对齐。
	local horizontalalignment, verticalalignment
	if layout.horizontalalignment == nil then horizontalalignment = "left"
	elseif unicode.to_lower_case(layout.horizontalalignment) == "left" or
		unicode.to_lower_case(layout.horizontalalignment) == "center" or
		unicode.to_lower_case(layout.horizontalalignment) == "right" then
		horizontalalignment = unicode.to_lower_case(layout.horizontalalignment)
	else log_error("horizontalalignment值的格式不正确。")
	end
	if layout.verticalalignment == nil then verticalalignment = "top"
	elseif unicode.to_lower_case(layout.verticalalignment) == "top" or
		unicode.to_lower_case(layout.verticalalignment) == "center" or
		unicode.to_lower_case(layout.verticalalignment) == "bottom" then
		verticalalignment = unicode.to_lower_case(layout.verticalalignment)
	else log_error("verticalalignment值的格式不正确。")
	end
	
	-- 几种条件下布局因为超出显示范围而无意义。
	if width == 0 or height == 0 or
		(horizontalalignment == "left" and margin.left >= rect.width) or
		(horizontalalignment == "right" and margin.right >= rect.width) or
		(verticalalignment == "top" and margin.top >= rect.height) or
		(verticalalignment == "bottom" and margin.bottom >= rect.height) then
		return nil, { width = 0, height = 0 }
	end
	
	local result, minsize
	-- 规划可用空间范围，若宽度或高度为auto，则使用可用的最大值。
	local avaliablerect = {
		x = nil,
		y = nil,
		width = width or util.clamp(rect.width - margin.left - margin.right, minwidth, maxwidth),
		height = height or util.clamp(rect.height - margin.top - margin.bottom, minheight, maxheight)
	}
	if horizontalalignment == "left" then avaliablerect.x = rect.x + margin.left
	elseif horizontalalignment == "center" then
		avaliablerect.x = rect.x + (rect.width - (avaliablerect.width + margin.left + margin.right)) / 2
	elseif horizontalalignment == "right" then
		avaliablerect.x = rect.x + rect.width - (avaliablerect.width + margin.left + margin.right)
	end
	if verticalalignment == "top" then avaliablerect.y = rect.y + margin.top
	elseif verticalalignment == "center" then
		avaliablerect.y = rect.y + (rect.height - (avaliablerect.height + margin.top + margin.bottom)) / 2
	elseif verticalalignment == "bottom" then
		avaliablerect.y = rect.y + rect.height - (avaliablerect.height + margin.top + margin.bottom)
	end
	
	if layout.layouttype == "text" then -- 文本布局
		local style = style_parse(styles, layout.style) -- 获取文本使用的样式。
		local wrappedtextminsize, wrappedtext = text_layout(style, avaliablerect, data.text) -- 进行文本布局。
		
		-- 计算文本的横向和纵向对齐。
		local texthorizontalalignment, textverticalalignment
		if layout.texthorizontalalignment == nil then texthorizontalalignment = "left"
		elseif unicode.to_lower_case(layout.texthorizontalalignment) == "left" or
			unicode.to_lower_case(layout.texthorizontalalignment) == "center" or
			unicode.to_lower_case(layout.texthorizontalalignment) == "right" then
			texthorizontalalignment = unicode.to_lower_case(layout.texthorizontalalignment)
		else log_error("texthorizontalalignment值的格式不正确。")
		end
		if layout.textverticalalignment == nil then textverticalalignment = "left"
		elseif unicode.to_lower_case(layout.textverticalalignment) == "left" or
			unicode.to_lower_case(layout.textverticalalignment) == "center" or
			unicode.to_lower_case(layout.textverticalalignment) == "right" then
			textverticalalignment = unicode.to_lower_case(layout.textverticalalignment)
		else log_error("textverticalalignment值的格式不正确。")
		end
		
		result = {
			layouttype = "text",
			rect = {
				x = nil,
				y = nil,
				width = (width or wrappedtextminsize.width) + margin.left + margin.right,
				height = (height or wrappedtextminsize.height) + margin.top + margin.bottom
			},
			texthorizontalalignment = unicode.to_lower_case(texthorizontalalignment),
			textverticalalignment = unicode.to_lower_case(textverticalalignment),
			text = content,
		}
		minsize = {
			width = wrappedtextminsize.width + margin.left + margin.right,
			height = wrappedtextminsize.height + margin.top + margin.bottom
		}
	elseif layout.layouttype == "flow" then -- 流式布局
		-- 计算横向和纵向间距。
		local horizontalspacing = tonumber(layout.horizontalspacing) or 0
		local verticalspacing = tonumber(layout.verticalspacing) or 0
		-- 计算布局方向。
		local orientation = {}
		if layout.orientation == nil or unicode.to_lower_case(layout.orientation) == "rightdown" or layout.orientation == 62 then
			orientation.primary = "right"
			orientation.secondary = "down"
		elseif unicode.to_lower_case(layout.orientation) == "rightup" or layout.orientation == 68 then
			orientation.primary = "right"
			orientation.secondary = "up"
		elseif unicode.to_lower_case(layout.orientation) == "leftdown" or layout.orientation == 42 then
			orientation.primary = "left"
			orientation.secondary = "down"
		elseif unicode.to_lower_case(layout.orientation) == "leftup" or layout.orientation == 48 then
			orientation.primary = "left"
			orientation.secondary = "up"
		elseif unicode.to_lower_case(layout.orientation) == "downleft" or layout.orientation == 24 then
			orientation.primary = "down"
			orientation.secondary = "left"
		elseif unicode.to_lower_case(layout.orientation) == "downright" or layout.orientation == 26 then
			orientation.primary = "down"
			orientation.secondary = "right"
		elseif unicode.to_lower_case(layout.orientation) == "upleft" or layout.orientation == 84 then
			orientation.primary = "up"
			orientation.secondary = "left"
		elseif unicode.to_lower_case(layout.orientation) == "upright" or layout.orientation == 86 then
			orientation.primary = "up"
			orientation.secondary = "right"
		else log_error("orientation值的格式不正确。")
		end
		
		--[[
		-- 计算内部布局的横向和纵向对齐。
		local contenthorizontalalignment, contentverticalalignment
		if layout.contenthorizontalalignment == nil then contenthorizontalalignment = "left"
		elseif unicode.to_lower_case(layout.contenthorizontalalignment) == "left" or
			unicode.to_lower_case(layout.contenthorizontalalignment) == "center" or
			unicode.to_lower_case(layout.contenthorizontalalignment) == "right" then
			contenthorizontalalignment = unicode.to_lower_case(layout.contenthorizontalalignment)
		else log_error("contenthorizontalalignment值的格式不正确。")
		end
		if layout.contentverticalalignment == nil then contentverticalalignment = "left"
		elseif unicode.to_lower_case(layout.contentverticalalignment) == "left" or
			unicode.to_lower_case(layout.contentverticalalignment) == "center" or
			unicode.to_lower_case(layout.contentverticalalignment) == "right" then
			contentverticalalignment = unicode.to_lower_case(layout.contentverticalalignment)
		else log_error("contentverticalalignment值的格式不正确。")
		end
		]]--
		
		-- 进行布局，将所有内部布局转化为以行为单元的表。
		local flowlines = {}
		local flowline = {}
		local flowlinelength = 0
		local maxflowlinelength, flowlinelengthspacing, flowlineheightspacing, getflowlinecontentlength, getflowlinecontentheight
		if orientation.primary == "right" or orientation.primary == "left" then
			maxflowlinelength = avaliablerect.width
			flowlinelengthspacing = horizontalspacing
			flowlineheightspacing = verticalspacing
			getflowlinecontentlength = function(contentminsize) return contentminsize.width end
			getflowlinecontentheight = function(contentminsize) return contentminsize.height end
		elseif orientation.primary == "top" or orientation.primary == "bottom" then
			maxflowlinelength = avaliablerect.height
			flowlinelengthspacing = verticalspacing
			flowlineheightspacing = horizontalspacing
			getflowlinecontentlength = function(contentminsize) return contentminsize.height end
			getflowlinecontentheight = function(contentminsize) return contentminsize.width end
		end
		for index, contentlayout in ipairs(layout) do
			local contentlayer = contentlayout.layer or layer + 1
			contentresult, contentminsize = measure_layout(line, styles, contentlayout, contentlayer, avaliablerect, data[index])
			if #flowline == 0 or flowlinelength + flowlinelengthspacing + getflowlinecontentlength(contentminsize) <= maxflowlinelength then
				table.insert(flowline, {
					layout = contentlayout,
					minsize = contentminsize,
					layer = contentlayer,
					horizontalalignment = contentresult.horizontalalignment,
					verticalalignment = contentresult.verticalalignment
				})
				flowlinelength = flowlinelength + flowlinelengthspacing + getflowlinecontentlength(contentminsize)
			else
				table.insert(flowlines, flowline)
				flowline = { {
					layout = contentlayout,
					minsize = contentminsize,
					layer = contentlayer,
					horizontalalignment = contentresult.horizontalalignment,
					verticalalignment = contentresult.verticalalignment
				} }
				flowlinelength = getflowlinecontentlength(contentminsize)
			end
		end
		if #flowline ~= 0 then
			table.insert(flowlines, flowline)
			flowline = nil
			flowlinelength = 0
		end
		
		-- 重新遍历每一行，以特殊的坐标系对各个内部布局进行定位。
		local flowlineheight = 0
		local maxflowlinelength = 0
		local flag1 = true
		for _, flowline in flowlines do
			if flag1 then flag1 = false
			else flowlineheight = flowlineheight + flowlineheightspacing
			end
			
			local flowlinelength = 0
			local maxflowlineheight = 0
			local flag2 = true
			for _, content in flowline do
				if flag2 then flag2 = false
				else flowlinelength = flowlinelength + flowlinelengthspacing
				end
				
				content.flowlinelengthposition = flowlinelength
				flowlinelength = flowlinelength + getflowlinecontentlength(content.minsize)
				maxflowlineheight = math.max(maxflowlineheight, getflowlinecontentheight(content.minsize))
			end
			flowline.length = flowlinelength
			flowline.height = maxflowlineheight
			flowline.flowlineheightposition = flowlineheight
			flowlineheight = flowlineheight + maxflowlineheight
			maxflowlinelength = math.max(maxflowlinelength, flowlinelength)
		end
		flowlines.length = maxflowlinelength
		flowlines.height = flowlineheight
		flowlines.flowlinelength = maxflowlinelength
		
		result = { layouttype = "flow" }
		if orientation.primary == "right" or orientation.primary == "left" then
			result.rect = {
				width = flowlines.length + margin.left + margin.right,
				height = flowline.height + margin.top + margin.bottom
			}
			minsize = {
				width = (width or flowlines.length) + margin.left + margin.right,
				height = (height or flowlines.height) + margin.top + margin.bottom
			}
		elseif orientation.primary == "top" or orientation.primary == "bottom" then
			result.rect = {
				width = flowlines.height + margin.left + margin.right,
				height = flowlines.length + margin.top + margin.bottom
			}
			minsize = {
				width = (width or flowlines.height) + margin.left + margin.right,
				height = (height or flowlines.length) + margin.top + margin.bottom
			}
		end

		-- 将特殊坐标系中的各内部布局映射到流式布局的新坐标系。
		local index = 1
		for _, flowline in ipairs(flowlines) do
			for _, content in ipairs(flowline) do
				-- 规划内部布局的可用空间范围。
				local contentavaliablerect = {
					width = getflowlinecontentlength(content.minsize),
					height = getflowlinecontentheight(content.minsize)
				}
				
				-- 坐标映射算法核心。
				if orientation.primary == "right" then
					contentavaliablerect.x = content.flowlinelengthposition
				elseif orientation.primary == "left" then
					contentavaliablerect.x = flowline.length - (content.flowlinelengthposition + content.minsize.width)
				elseif orientation.primary == "down" then
					contentavaliablerect.y = content.flowlinelengthposition
				elseif orientation.primary == "up" then
					contentavaliablerect.y = flowline.length - (content.flowlinelengthposition + content.minsize.height)
				end
				if orientation.secondary == "down" then
					if content.verticalalignment == "top" then
						contentavaliablerect.y = content.flowlineheightposition
					elseif content.verticalalignment == "center" then
						contentavaliablerect.y = content.flowlineheightposition + (flowline.height - content.minsize.height) / 2
					elseif content.verticalalignment == "bottom" then
						contentavaliablerect.y = content.flowlineheightposition + (flowline.height - content.minsize.height)
					end
				elseif orientation.secondary == "up" then
					if content.verticalalignment == "top" then
						contentavaliablerect.y = flowlines.height - (content.flowlineheightposition + flowline.height)
					elseif content.verticalalignment == "center" then
						contentavaliablerect.y = flowlines.height - (content.flowlineheightposition + flowline.height) + (flowline.height - content.minsize.height) / 2
					elseif content.verticalalignment == "bottom" then
						contentavaliablerect.y = flowlines.height - (content.flowlineheightposition + flowline.height) + (flowline.height - content.minsize.height)
					end
				elseif orientation.secondary == "right" then
					if content.horizontalalignment == "left" then
						contentavaliablerect.x = content.flowlineheightposition
					elseif content.horizontalalignment == "center" then
						contentavaliablerect.x = content.flowlineheightposition + (flowline.height - content.minsize.width) / 2
					elseif content.horizontalalignment == "right" then
						contentavaliablerect.x = content.flowlineheightposition + (flowline.height - content.minsize.width)
					end
				elseif orientation.secondary == "left" then
					if content.horizontalalignment == "left" then
						contentavaliablerect.res_x = flowlines.height - (content.flowlineheightposition + flowline.height)
					elseif content.horizontalalignment == "center" then
						contentavaliablerect.x = flowlines.height - (content.flowlineheightposition + flowline.height) + (flowline.height - content.minsize.width) / 2
					elseif content.horizontalalignment == "right" then
						contentavaliablerect.x = flowlines.height - (content.flowlineheightposition + flowline.height) + (flowline.height - content.minsize.width)
					end
				end

				-- 以内部布局的可用空间范围重新进行布局。
				contentresult, contentminsize = measure_layout(line, styles, content.layout, content.layer, contentavaliablerect, data[index])
				
				-- 将计测算好的内部布局插入父布局。
				table.insert(result, contentresult)

				index = index + 1
			end
		end
	elseif layout.layouttype == "stack" then -- 栈式布局
		-- 计算布局方向。
		local orientation
		if layout.orientation == nil then orientation = "down"
		elseif unicode.to_lower_case(layout.orientation) == "down" or
			unicode.to_lower_case(layout.orientation) == "right" or
			unicode.to_lower_case(layout.orientation) == "up" or
			unicode.to_lower_case(layout.orientation) == "left" then
			orientation = unicode.to_lower_case(layout.orientation)
		else log_error("orientation值的格式不正确。")
		end

	elseif layout.layouttype == "table" then -- 表式布局
	end
	
	result.layer = layer
	result.horizontalalignment = horizontalalignment
	result.verticalalignment = verticalalignment
	result.move = function(self, offsetx, offsety)
		for _, content in ipairs(self) do
			content.rect.x = content.rect.x + offsetx
			content.rect.y = content.rext.y + offsety
			content:move(offsetx, offsety)
		end
	end
end

local style_parse = function(styles, style)
	if type(style) == string then
		return styles[style]
	elseif type(style) == "table" then
		local override = util.copy(style_parse(style.override))
		return override
	end
end

local text_layout = function(style, size, data)
	regexresult = regexutil.match("\\s+(?=\\S|$)|[\\dA-Za-z]+(?=[^\\dA-Za-z]|$)|\\b.+?\\b|\\S+(?=\\s|$)", data)
	
	local linebuffer = {}
	local spanbuffer = {}
	for _, match in ipairs(regexresult) do
		local wrappable
		if re.find("^(\\s+|[\\dA-Za-z]+)$", match.str) then wrappable = false
		else wrappable = true
		end
		
		table.insert(spanbuffer, match.str)
		while true do
			local w, h, d, el = aegis.text_extents(style, table.concat(spanbuffer))
			if w <= size.width then break
			elseif wrappable or #spanbuffer == 1 then
				table.remove(spanbuffer, #spanbuffer)
				
				for c in unicode.chars(match.str) do
					table.insert(spanbuffer, c)
					local w, h, d, el = aegis.text_extents(style, table.concat(spanbuffer))
					if #spanbuffer > 1 and w > size.width then
						table.remove(spanbuffer, #spanbuffer)
						table.insert(linebuffer, table.concat(spanbuffer))
						spanbuffer = {}
						table.insert(spanbuffer, c)
					end
				end
				if #spanbuffer > 1 then
					spanbuffer = { table.concat(spanbuffer) }
				end
			else
				table.remove(spanbuffer, #spanbuffer)
				table.insert(linebuffer, table.concat(spanbuffer))
				spanbuffer = {}
				table.insert(spanbuffer, match.str)
			end
		end
	end
	if #spanbuffer ~= 0 then
		table.insert(linebuffer, table.concat(spanbuffer))
		spanbuffer = {}
	end
	
	local wrappedtext = table.concat(linebuffer, "\\N")
	local w, h, d, el = aegis.text_extents(style, table.concat(wrappedtext))
	return { width = w, height = h }, wrappedtext
end

aegisub.register_macro(script_name, script_description, process_main)
