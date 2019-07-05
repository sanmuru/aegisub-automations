-- Copyright (c) 2019, Sam Lu

include("karaskel.lua")
regexutil = require("aegisub.re")
util = require("aegisub.util")

script_name = "生成聊天室特效字幕"
script_description = "将原有的文本转化为聊天室特效字幕。"
script_author = "Sam Lu"
script_version = "0.1.20190317"

debug.fatal = function(msg, ...) aegisub.debug.out(1, msg, ...) end

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
            aegisub.debug.out()

        end
    end

    local line
    if layouts[line.effect] ~= nil then
        local layout = layouts[line.effect]
        if layout.layer == nil then layout.layer = 0 end
    end
end

--[[ 测算布局
---- 参数：
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
		else debug.fatal("margin值的格式不正确。")
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
        else debug.fatal("margin值的格式不正确。")
        end
    else debug.fatal("margin值的格式不正确。")
    end
    
	-- 计算宽度和高度的最小值和最大值。
    local minwidth, maxwidth, minheight, maxheight
    if layout.minwidth == nil then minwidth = 0
    elseif tonumber(layout.minwidth) ~= nil then
        minwidth = tonumber(layout.minwidth)
        if minwidth < 0 then debug.fatal("minwidth值不应小于零。") end
    else debug.fatal("minwidth值的格式不正确。")
    end
    if layout.maxwidth == nil then ;
    elseif tonumber(layout.maxwidth) ~= nil then
        maxwidth = tonumber(layout.maxwidth)
        if maxwidth < minwidth then debug.fatal("maxwidth值不应小于minwidth。") end
    else debug.fatal("minwidth值的格式不正确。")
    end
    if layout.minheight == nil then minheight = 0
    elseif tonumber(layout.minheight) ~= nil then
        minheight = tonumber(layout.minheight)
        if minheight < 0 then debug.fatal("minheight值不应小于零。") end
    else debug.fatal("minheight值的格式不正确。")
    end
    if layout.maxheight == nil then ;
    elseif tonumber(layout.maxheight) ~= nil then
        maxheight = tonumber(layout.maxheight)
        if maxheight < minheight then debug.fatal("maxheight值不应小于minheight。") end
    else debug.fatal("minheight值的格式不正确。")
    end
	
	-- 计算宽度和高度。
    local width, height
    if tonumber(layout.width) == nil then -- 非数字类型值
        if unicode.to_lower_case(layout.width) == "fill" then width = math.max(0, rect.width - margin.left - margin.right) -- 填充
        elseif unicode.to_lower_case(layout.width) ~= "auto" then debug.fatal("width值应为数值、fill或auto。")
        --else -- 自动
        end
    else -- 数字类型值
        if type(layout.width) == "number" then width = layout.width
        else width = tonumber(layout.width)
        end
        if width < 0 then debug.fatal("width值不应小于零。") end
    end
    if width < minwidth then width = minwidth
    elseif maxwidth ~= nil and width > maxwidth then width = maxwidth
    end
	if tonumber(layout.height) == nil then -- 非数字类型值
        if unicode.to_lower_case(layout.height) == "fill" then height = math.max(0, rect.height - margin.top - margint.bottom) -- 填充
        elseif unicode.to_lower_case(layout.height) ~= "auto" then debug.fatal("height值应为数值、fill或auto。")
        --else -- 自动
        end
    else -- 数字类型值
        if type(layout.height) == "number" then height = layout.height
        else height = tonumber(layout.height)
        end
        if height < 0 then debug.fatal("height值不应小于零。") end
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
	else debug.fatal("horizontalalignment值的格式不正确。")
	end
	if layout.verticalalignment == nil then verticalalignment = "top"
	elseif unicode.to_lower_case(layout.verticalalignment) == "top" or
		unicode.to_lower_case(layout.verticalalignment) == "center" or
		unicode.to_lower_case(layout.verticalalignment) == "bottom" then
		verticalalignment = unicode.to_lower_case(layout.verticalalignment)
	else debug.fatal("verticalalignment值的格式不正确。")
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
		else debug.fatal("texthorizontalalignment值的格式不正确。")
		end
		if layout.textverticalalignment == nil then textverticalalignment = "left"
		elseif unicode.to_lower_case(layout.textverticalalignment) == "left" or
			unicode.to_lower_case(layout.textverticalalignment) == "center" or
			unicode.to_lower_case(layout.textverticalalignment) == "right" then
			textverticalalignment = unicode.to_lower_case(layout.textverticalalignment)
		else debug.fatal("textverticalalignment值的格式不正确。")
		end
		
		result = {
			layouttype = "text",
			rect = {
				x = nil,
				y = nil,
				width = wrappedtextminsize.width,
				height = wrappedtextminsize.height
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
		local orientation
		if layout.orientation == nil then orientation = "rightdown"
		elseif unicode.to_lower_case(layout.orientation) == "rightdown" or
			unicode.to_lower_case(layout.orientation) == "rightup" or
			unicode.to_lower_case(layout.orientation) == "leftdown" or
			unicode.to_lower_case(layout.orientation) == "leftup" or
			unicode.to_lower_case(layout.orientation) == "downleft" or
			unicode.to_lower_case(layout.orientation) == "downright" or
			unicode.to_lower_case(layout.orientation) == "upleft" or
			unicode.to_lower_case(layout.orientation) == "upright" then
			orientation = unicode.to_lower_case(layout.orientation)
		elseif layout.orientation == 62 then
			orientation = "rightdown"
		elseif layout.orientation == 68 then
			orientation = "rightup"
		elseif layout.orientation == 42 then
			orientation = "leftdown"
		elseif layout.orientation == 48 then
			orientation = "leftup"
		elseif layout.orientation == 24 then
			orientation = "downleft"
		elseif layout.orientation == 26 then
			orientation = "downright"
		elseif layout.orientation == 84 then
			orientation = "upleft"
		elseif layout.orientation == 86 then
			orientation = "upright"
		else debug.fatal("orientation值的格式不正确。")
		end
		
		local flowlines = {}
		local flowline = {}
		local flowlinelength = 0
		local maxflowlinelength, getflowlinelengthincrement
		if string.sub(orientation, 1, 5) == "right" or string.sub(orientation, 1, 4) == "left" then
			maxflowlinelength = avaliablerect.width
			getflowlinelengthincrement = function(contentminsize, withspacing)
				return (withspacing and {1} or {0})[1] * horizontalspacing + contentminsize.width
			end
		else
			maxflowlinelength = avaliablerect.height
			getflowlinelengthincrement = function(contentminsize)
				return (withspacing and {1} or {0})[1] * verticalspacing + contentminsize.height
			end
		end
		for index, contentlayout in ipairs(layout) do
            local contentlayer = contentlayout.layer or layer + 1
			_, contentminsize = measure_layout(line, styles, contentlayout, contentlayer, avaliablerect, data[index])
			local flowlinelengthincrement = getflowlinelengthincrement(contentminsize, true)
			if #flowline == 0 or flowlinelength + flowlinelengthincrement <= maxflowlinelength then
				table.insert(flowline, contentlayout)
				flowlinelength == flowlinelength + flowlinelengthincrement
			else
				table.insert(flowlines, flowline)
				flowline = { contentlayout }
				flowlinelength = getflowlinelengthincrement(contentminsize, false)
			end
		end
		if #flowline ~= 0 then
			table.insert(flowlines, flowline)
			flowline = nil
			flowlinelength = 0
		end
	end
	
	result.layer = layer
	result.horizontalalignment = horizontalalignment
	result.verticalalignment = verticalalignment
	result.move = function(self, offsetx, offsety)
		for _, content in ipairs(self) do
			content.rect.x == content.rect.x + offsetx
			content.rect.y == content.rext.y + offsety
			content:move(offsetx, offsety)
		end
	end
	if horizontalalignment


    local contentheight, contentwidth = 0, 0
    if layout.layouttype == "stack" then
        for i = 1, #layout do
            local contentlayout = layout[i]
            local contentlayer = contentlayout.layer or layer + 1
            local measurerect
            if height == nil then
                
            end
            temprect, minrect = measure_layout(line, styles, contentlayout, contentlayer, measurerect)
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
