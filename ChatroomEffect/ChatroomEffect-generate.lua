-- Copyright (c) 2019, Sam Lu

include("karaskel.lua")
regexutil = require("aegisub.re")
util = require("aegisub.util")
interop = require("chatroomeffect.interop")

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
	do_layout(lines, actors, layouts)
end

local do_layout = function(lines, actors, layouts)
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
		if layout.layer == nil then layout.layer = 0 end
	end
end

local preprocess_layout = function(layout_content, userdata)
	local preprocess = function(code, data)
		local regexresult = regexutil.find("^(?=\\$\\().*(?=\\))$", code)
		if regexresult then
			return loadstring("return function(self) return {"..regexresult[1].str.."} end")(data)
		else return code
		end
	end

	for key, value in pairs(layout_content) do
		if type(value) == "string" then
			layout_content[key] = value
		elseif type(value) == "table" then
			if key == "templates" then -- 若当前键的值是模板定义
				-- 现在不处理，待展开模板时处理。
			else
				preprocess_layout(value, userdata)
			end
		end
	end
end

--[[ 测算布局。
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
	-- 计算margin。
	local margin
	if layout.margin == nil then margin = { left = 0, right = 0, top = 0, bottom = 0 }
	elseif tonumber(layout.margin) ~= nil then margin = { left = tonumber(layout.margin), right = tonumber(layout.margin), top = tonumber(layout.margin), bottom = tonumber(layout.margin) }
	elseif type(layout.margin) == "string" then
		if util.trim(layout.margin) == "" then margin = { left = 0, right = 0, top = 0, bottom = 0 }
		elseif regexutil.find("^\\s*(\\d*\\.\\d*|\\d+)(\\s*,\\s*(\\d*\\.\\d*|\\d+)){1,3}\\s*$", layout.margin) then
			regexresult = regexutil.find("(?:(^|,)\\s*)\\d*\\.\\d*|\\d+(?:\\s*($|,))", layout.margin)
			if #regexresult == 2 then
				margin = {
					left = tonumber(regexresult[1].str),
					right = tonumber(regexresult[1].str),
					top = tonumber(regexresult[2].str),
					bottom = tonumber(regexresult[2].str)
				}
			elseif #regexresult == 4 then
				margin = {
					left = tonumber(regexresult[1].str),
					right = tonumber(regexresult[2].str),
					top = tonumber(regexresult[3].str),
					bottom = tonumber(regexresult[4].str)
				}
			else log_error("margin值的格式不正确。")
			end
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
	else log_error("margin值的格式不正确。")
	end
	
	-- 计算宽度和高度的最小值和最大值。
	local minwidth, maxwidth, minheight, maxheight
	if layout.minwidth == nil then minwidth = 0
	elseif tonumber(layout.minwidth) ~= nil then
		minwidth = tonumber(layout.minwidth)
		if minwidth < 0 then log_error("minwidth值不应小于零。") end
	else log_error("minwidth值的格式不正确。")
	end
	if layout.maxwidth == nil then ;
	elseif tonumber(layout.maxwidth) ~= nil then
		maxwidth = tonumber(layout.maxwidth)
		if maxwidth < minwidth then log_error("maxwidth值不应小于minwidth。") end
	else log_error("minwidth值的格式不正确。")
	end
	if layout.minheight == nil then minheight = 0
	elseif tonumber(layout.minheight) ~= nil then
		minheight = tonumber(layout.minheight)
		if minheight < 0 then log_error("minheight值不应小于零。") end
	else log_error("minheight值的格式不正确。")
	end
	if layout.maxheight == nil then ;
	elseif tonumber(layout.maxheight) ~= nil then
		maxheight = tonumber(layout.maxheight)
		if maxheight < minheight then log_error("maxheight值不应小于minheight。") end
	else log_error("minheight值的格式不正确。")
	end
	
	-- 计算宽度和高度。
	local width, height
	if tonumber(layout.width) == nil then -- 非数字类型值
		if unicode.to_lower_case(layout.width) == "fill" and rect.width ~= nil then -- 填充
			width = rect.width - margin.left - margin.right
		elseif unicode.to_lower_case(layout.width) ~= "auto" then
			log_error("width值应为数值、fill或auto。")
		--else -- 自动
		end
	else -- 数字类型值
		width = tonumber(layout.width)
		if width < 0 then log_error("width值不应小于零。") end
	end
	if width < minwidth then width = minwidth
	elseif maxwidth ~= nil and width > maxwidth then width = maxwidth
	end
	if tonumber(layout.height) == nil then -- 非数字类型值
		if unicode.to_lower_case(layout.height) == "fill" and rect.height ~= nil then
			height = rect.height - margin.top - margint.bottom -- 填充
		elseif unicode.to_lower_case(layout.height) ~= "auto" then
			log_error("height值应为数值、fill或auto。")
		--else -- 自动
		end
	else -- 数字类型值
		height = tonumber(layout.height)
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
	if width <= 0 or height <= 0 -- fill模式下计算得出的宽度和高度不大于零。
	--[[ or
		(horizontalalignment == "left" and margin.left >= rect.width) or
		(horizontalalignment == "right" and margin.right >= rect.width) or
		(verticalalignment == "top" and margin.top >= rect.height) or
		(verticalalignment == "bottom" and margin.bottom >= rect.height)
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
	
	if layout.layouttype == "text" then -- 文本布局
		-- 获取文本使用的样式。
		local style = style_parse(styles, layout.style)

		-- 计算文本换行方式
		local wordwrap
		if layout.wordwrap == nil then wordwrap = "none"
		elseif unicode.to_lower_case(layout.wordwrap) == "none" or
			unicode.to_lower_case(layout.wordwrap) == "hard" or
			unicode.to_lower_case(layout.wordwrap) == "soft" then
			wordwrap = unicode.to_lower_case(layout.wordwrap)
		else log_error("wordwrap值的格式不正确。")
		end

		-- 获取文本。
		local text
		if type(layout.text) == string then text = layout.text
		else text = ""
		end
		-- 进行文本布局。
		local wrappedtextminsize, wrappedtext = text_layout(style, wordwrap, avaliablerect, text)
		
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
				width = wrappedtextminsize.width,
				height = wrappedtextminsize.height
			},
			texthorizontalalignment = texthorizontalalignment,
			textverticalalignment = textverticalalignment,
			text = wrappedtext
		}
		minsize = {
			width = wrappedtextminsize.width,
			height = wrappedtextminsize.height
		}
	elseif layout.layouttype == "image" then -- 图像布局
		-- 计算图像的缩放模式。
		local scalemode
		if layout.scalemode == nil then scalemode = "aspectfit"
		elseif unicode.to_lower_case(layout.scalemode) == "none" or
			unicode.to_lower_case(layout.scalemode) == "fill" or
			unicode.to_lower_case(layout.scalemode) == "aspectfit" or
			unicode.to_lower_case(layout.scalemode) == "aspectfill" then
			scalemode = unicode.to_lower_case(layout.scalemode)
		else log_error("scalemode值的格式不正确。")
		end
		
		-- 获取图片信息
		local image = image_parse(layout.image)

		local newimagesize
		if scalemode == "none" then -- 图片长宽不变，不进行拉伸。
			newimagesize = {
				width = image.rect.width,
				height = image.rect.height
			}
		elseif scalemode == "fill" then -- 图片拉伸或缩小以适应可用范围，长宽比可能改变。
			newimagesize = {
				width = avaliablerect.width or image.rect.width,
				height = avaliablerect.height or image.rect.height
			}
		elseif scalemode == "aspectfit" then -- 图片拉伸或缩小到最佳大小以完整显示，但不一定充满整个可用范围，保持长宽比不变。
			local scale = math.min((avaliablerect.width or image.rect.width) / image.rect.width, (avaliablerect.height or image.rect.height) / image.rect.height)
			newimagesize = {
				width = math.floor(image.rect.width * scale + 0.5),
				height = math.floor(image.rect.height * scale + 0.5)
			}
		elseif scalemode == "aspectfill" then -- 图片在不改变长宽比的前提下拉伸或缩小，它充满整个可用范围，但可能会被裁剪。
			local scale = math.max((avaliablerect.width or image.rect.width) / image.rect.width, (avaliablerect.height or image.rect.height) / image.rect.height)
			newimagesize = {
				width = math.floor(image.rect.width * scale + 0.5),
				height = math.floor(image.rect.height * scale + 0.5)
			}
		end
		image.scaleto = newimagesize
		result = {
			layouttype = "image",
			rect = {
				x = nil,
				y = nil,
				width = newimagesize.width,
				height = newimagesize.height
			},
			image = image,
		}
		minsize = newimagesize
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
		--]]
		
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
		
		local contentavaliablerect = {
			x = avaliablerect.x,
			y = avaliablerect.y,
			width = avaliablerect.width,
			height = avaliablerect.height
		}
		for index, contentlayout in ipairs(layout) do
			local contentlayer = contentlayout.layer or layer + 1
			local _, contentminsize = measure_layout(line, styles, contentlayout, contentlayer, contentavaliablerect, data[index])
			if layout.orientation == "down" then
				local contentrect = {
					x = contentavaliablerect.x,
					y = contentavaliablerect.y,
					width = contentavaliablerect.width,
					height = contentminsize.height
				}
				local contentresult, contentminsize = measure_layout(line, styles, contentlayout, contentlayer, contentrect, data[index])
				table.insert(result, contentresult)
				
				contentavaliablerect.y = contentavaliablerect.y + contentrect.height
				contentavaliablerect.height = contentavaliablerect.height - contentrect.height
			elseif layout.orientation == "up" then
				local contentrect = {
					x = contentavaliablerect.x,
					y = contentavaliablerect.height - contentminsize.height,
					width = contentavaliablerect.width,
					height = contentminsize.height
				}
				local contentresult, contentminsize = measure_layout(line, styles, contentlayout, contentlayer, contentrect, data[index])
				table.insert(result, contentresult)
				
				contentavaliablerect.height = contentavaliablerect.height - contentrect.height
			elseif layout.orientation == "right" then
				local contentrect = {
					x = contentavaliablerect.x,
					y = contentavaliablerect.y,
					width = contentminsize.width,
					height = contentavaliablerect.height
				}
				local contentresult, contentminsize = measure_layout(line, styles, contentlayout, contentlayer, contentrect, data[index])
				table.insert(result, contentresult)
				
				contentavaliablerect.x = contentavaliablerect.x + contentrect.width
				contentavaliablerect.width = contentavaliablerect.width - contentrect.width
			elseif layout.orientation == "left" then
				local contentrect = {
					x = contentavaliablerect.width - contentminsize.width,
					y = contentavaliablerect.y,
					width = contentminsize.width,
					height = contentavaliablerect.height
				}
				local contentresult, contentminsize = measure_layout(line, styles, contentlayout, contentlayer, contentrect, data[index])
				table.insert(result, contentresult)
				
				contentavaliablerect.width = contentavaliablerect.width - contentrect.width
			end
			
			if contentavaliablerect.width <= 0 or contentavaliablerect.height <= 0 then break end
		end
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

--[[ 测算文本布局
---- 参数： style, wordwrap, size, text
	style: 文本使用的。
	wordwrap: 文本的换行模式。
	size: 用于布局的预留范围。
	text: 需要测算的文本。
---- 返回： minsize, wrappedtext
	 minsize: 布局后文本占用的矩形的最小范围。
	 wrappedtext: 布局后的文本。
--]]
local text_layout = function(style, wordwrap, size, text)
	local rawlines = regexutil.split(text, "\\r?\\n")
	local linebuffer = { length = 0 }
	for _, rawline in ipairs(rawlines) do
		if rawline == "" then -- 若为空行，则高度为样式的字体大小的一半。
			table.insert(linebuffer, rawline)
			linebuffer.height = linebuffer.height + style.fontsize / 2
		else
			if wordwrap == "none" then -- 不换行
				table.insert(linebuffer, rawline)
				local w, h, d, el = aegisub.text_extents(style, rawline)
				linebuffer.length = math.max(linebuffer.length, w)
				linebuffer.height = linebuffer.height + h
			else
				regexresult = regexutil.match("\\s+(?=\\S|$)|[\\dA-Za-z]+(?=[^\\dA-Za-z]|$)|\\b.+?\\b|\\S+(?=\\s|$)", rawline)
				
				local spanbuffer = {}
				for _, match in ipairs(regexresult) do
					local wrappable
					if wordwrap == "hard" then -- 硬换行
						wrappable = true -- 所有文本段均能逐字换行。
					elseif wordwrap == "soft" then -- 软换行
						if regexutil.find("^(\\s+|[\\dA-Za-z]+)$", match.str) then wrappable = false -- 仅数字和字母相连的组合不能逐字换行。
						else wrappable = true -- 其余组合均能逐字换行。
						end
					end
					
					table.insert(spanbuffer, match.str)
					while true do
						local w, h, d, el = aegisub.text_extents(style, table.concat(spanbuffer))
						if size.width == nil or w <= size.width then break
						elseif wrappable or #spanbuffer == 1 then
							table.remove(spanbuffer, #spanbuffer)
							
							for c in unicode.chars(match.str) do
								table.insert(spanbuffer, c)
								local w, h, d, el = aegisub.text_extents(style, table.concat(spanbuffer))
								if #spanbuffer > 1 and size.width ~= nil and w > size.width then
									table.remove(spanbuffer, #spanbuffer)
									spanbuffer.length, spanbuffer.height = aegisub.text_extents(style, table.concat(spanbuffer))
									table.insert(linebuffer, table.concat(spanbuffer))
									linebuffer.length = math.max(linebuffer.length, spanbuffer.length)
									linebuffer.height = linebuffer.height + spanbuffer.height
									spanbuffer = {}
									table.insert(spanbuffer, c)
								end
							end
							if #spanbuffer > 1 then
								spanbuffer = { table.concat(spanbuffer) }
							end
						else
							table.remove(spanbuffer, #spanbuffer)
							spanbuffer.length, spanbuffer.height = aegisub.text_extents(style, table.concat(spanbuffer))
							table.insert(linebuffer, table.concat(spanbuffer))
							linebuffer.length = math.max(linebuffer.length, spanbuffer.length)
							linebuffer.height = linebuffer.height + spanbuffer.height
							spanbuffer = {}
							table.insert(spanbuffer, match.str)
						end
					end
				end
				if #spanbuffer ~= 0 then
					spanbuffer.length, spanbuffer.height = aegisub.text_extents(style, table.concat(spanbuffer))
					table.insert(linebuffer, table.concat(spanbuffer))
					linebuffer.length = math.max(linebuffer.length, spanbuffer.length)
					linebuffer.height = linebuffer.height + spanbuffer.height
					spanbuffer = {}
				end
			end
		end
	end
	
	local wrappedtext = table.concat(linebuffer, "\\N")
	return { width = linebuffer.length, height = linebuffer.height }, wrappedtext
end

local image_parse = function(image)
	if image == nil then return nil
	elseif type(image) == "string" then
		local info = interop.image.getinfo[image]
		return {
			source = info,
			rect = {
				x = 0,
				y = 0,
				width = info.width,
				height = info.height
			}
		}
	elseif type(image) == "table" then
		if type(image.source) == "string" then
			local info = interop.image.getinfo[image.source]
			return {
				source = info,
				rect = {
					x = tonumber(image.x) or 0,
					y = tonumber(image.y) or 0,
					width = tonumber(image.width) or info.width,
					height = tonumber(image.height) or info.height
				}
			}
		else log_error("source值的格式不正确。")
		end
	end

	log_error("image值的格式不正确。")
end


aegisub.register_macro(script_name, script_description, process_main)