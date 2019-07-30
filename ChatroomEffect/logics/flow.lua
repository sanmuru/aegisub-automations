local layoututil = require("chatroomeffect.layoututil")

local logic = {}

logic.type = "flow"
logic.priority = 100

logic.measure_minsize = function(layout, size, meta, data)
	-- 获取布局的元数据。
	meta = parse_meta(layout, size, meta, data)
	
	-- 进行流式布局。
	local flowlines = flow_layout(meta, size)

	if meta.orientation.primary == "right" or meta.orientation.primary == "left" then
		return {
			width = flowlines.width,
			height =flowlines.height
		}
	elseif meta.orientation.primary == "top" or meta.orientation.primary == "bottom" then
		return {
			width = flowlines.height,
			height = flowlines.width
		}
	end
end

logic.do_layout = function(layout, rect, meta, data)
	-- 获取布局的元数据。
	meta = parse_meta(layout, size, meta, data)
	
	-- 进行流式布局。
	local flowlines = flow_layout(meta, size)
	
	result = { layouttype = "flow" }
	if meta.orientation.primary == "right" or meta.orientation.primary == "left" then
		result.rect = {
			width = flowlines.length,
			height = flowline.height
		}
	elseif meta.orientation.primary == "top" or meta.orientation.primary == "bottom" then
		result.rect = {
			width = flowlines.height,
			height = flowlines.length
		}
	end
	
	-- 将特殊坐标系中的各内部布局映射到流式布局的新坐标系。
	local index = 1
	for _, flowline in ipairs(flowlines) do
		for _, content in ipairs(flowline) do
			-- 规划内部布局的可用空间范围。
			local contentavaliablerect = {
				x = nil,
				y = nil,
				width = contentminsize.width,
				height = contentminsize.height
			}
				
			-- 坐标映射算法核心。
			if meta.orientation.primary == "right" then
				contentavaliablerect.x = rect.x + content.lengthposition
			elseif meta.orientation.primary == "left" then
				contentavaliablerect.x = rect.x + flowlines.length - content.lengthposition - content.minsize.width
			elseif meta.orientation.primary == "down" then
				contentavaliablerect.y = rect.y + content.lengthposition
			elseif meta.orientation.primary == "up" then
				contentavaliablerect.y = rect.y + flowline.length - content.lengthposition - content.minsize.height
			end
			if meta.orientation.secondary == "down" then
				contentavaliablerect.y = rect.y + content.lengthposition
			elseif meta.orientation.secondary == "up" then
				contentavaliablerect.y = rect.y + flowline.length - content.lengthposition - content.minsize.height
			elseif meta.orientation.secondary == "right" then
				contentavaliablerect.x = rect.x + content.lengthposition
			elseif meta.orientation.secondary == "left" then
				contentavaliablerect.x = rect.x + flowlines.length - content.lengthposition - content.minsize.width
			end

			-- 以内部布局的可用空间范围重新进行布局。
			contentresult = layoututil.do_layout(content.layout, meta.layout, contentavaliablerect, data)
				
			-- 将计测算好的内部布局插入父布局。
			table.insert(result, contentresult)

			index = index + 1
		end
	end
	
	return result
end

local parse_meta = function(layout, size, data, meta)
	meta = util.copy(meta or {})

	-- 计算行高。
	if tonumber(layout.lineheight) == nil then meta.lineheight = nil
	elseif tonumber(layout.lineheight) < 0 then log_error("lineheight值不应小于零。")
	else meta.lineheight = tonumber(layout.lineheight)
	end

	-- 计算横向和纵向间距。
	meta.horizontalspacing = tonumber(layout.horizontalspacing) or 0
	meta.verticalspacing = tonumber(layout.verticalspacing) or 0

	-- 计算布局方向。
	meta.orientation = {}
	if layout.orientation == nil or unicode.to_lower_case(layout.orientation) == "rightdown" or tonumber(layout.orientation) == 62 then
		meta.orientation.primary = "right"
		meta.orientation.secondary = "down"
	elseif unicode.to_lower_case(layout.orientation) == "rightup" or tonumber(layout.orientation) == 68 then
		meta.orientation.primary = "right"
		meta.orientation.secondary = "up"
	elseif unicode.to_lower_case(layout.orientation) == "leftdown" or tonumber(layout.orientation) == 42 then
		meta.orientation.primary = "left"
		meta.orientation.secondary = "down"
	elseif unicode.to_lower_case(layout.orientation) == "leftup" or tonumber(layout.orientation) == 48 then
		meta.orientation.primary = "left"
		meta.orientation.secondary = "up"
	elseif unicode.to_lower_case(layout.orientation) == "downleft" or tonumber(layout.orientation) == 24 then
		meta.orientation.primary = "down"
		meta.orientation.secondary = "left"
	elseif unicode.to_lower_case(layout.orientation) == "downright" or tonumber(layout.orientation) == 26 then
		meta.orientation.primary = "down"
		meta.orientation.secondary = "right"
	elseif unicode.to_lower_case(layout.orientation) == "upleft" or tonumber(layout.orientation) == 84 then
		meta.orientation.primary = "up"
		meta.orientation.secondary = "left"
	elseif unicode.to_lower_case(layout.orientation) == "upright" or tonumber(layout.orientation) == 86 then
		meta.orientation.primary = "up"
		meta.orientation.secondary = "right"
	else log_error("orientation值的格式不正确。")
	end
	
	return meta
end

--[[ 进行流式布局。
---- 参数： meta, size, text
	meta: 解释布局得到的元数据。
	size: 用于布局的预留范围。
---- 返回： flowlines
	flowlines: 以复数个子布局组成的行的列表。
--]]
local flow_layout = function(meta, size)
	-- 进行布局，将所有内部布局转化为以行为单元的表。
	local flowlines = { length = 0, height = 0 }
	local flowline = { length = 0, height = 0 }
	local maxflowlinelength, flowlinelengthspacing, flowlineheightspacing, getflowlinecontentlength, getflowlinecontentheight
	local contentavaliablerectsize = { width = nil, height = nil }
	if meta.orientation.primary == "right" or meta.orientation.primary == "left" then
		maxflowlinelength = size.width
		flowlinelengthspacing = meta.horizontalspacing
		flowlineheightspacing = meta.verticalspacing
		getflowlinecontentlength = function(contentminsize) return contentminsize.width end
		getflowlinecontentheight = function(contentminsize) return contentminsize.height end
		contentavaliablerectsize.width = maxflowlinelength
		contentavaliablerectsize.height = meta.lineheight
	elseif meta.orientation.primary == "top" or meta.orientation.primary == "bottom" then
		maxflowlinelength = size.height
		flowlinelengthspacing = meta.verticalspacing
		flowlineheightspacing = meta.horizontalspacing
		getflowlinecontentlength = function(contentminsize) return contentminsize.height end
		getflowlinecontentheight = function(contentminsize) return contentminsize.width end
		contentavaliablerectsize.width = meta.lineheight
		contentavaliablerectsize.height = maxflowlineheight
	end
	for index, contentlayout in ipairs(layout) do
		contentminsize = layoututil.measure_minsize(contentlayout, contentavaliablerectsize, data)
		if #flowline == 0 or maxflowlinelength == nil or flowline.length + flowlinelengthspacing + getflowlinecontentlength(contentminsize) <= maxflowlinelength then
			table.insert(flowline, {
				layout = contentlayout,
				minsize = contentminsize,
				lengthposition = flowline.length,
				heightposition = flowlines.height
			})
			if #flowline > 1 then flowline.length = flowline.length + flowlinelengthspacing end
			flowline.length = flowline.length + getflowlinecontentlength(contentminsize)
			flowline.height = math.max(flowline.height, getflowlinecontentheight(contentminsize))
		else
			table.insert(flowlines, flowline)
			flowlines.length = math.max(flowlines.length, flowline.length)
			if #flowlines > 1 then flowlines.height = flowlines.height + flowlineheightspacing end
			flowlines.height = flowlines.height + flowline.height

			flowline = { length = nil , height = nil }
			table.insert(flowline, {
				layout = contentlayout,
				minsize = contentminsize,
				lengthposition = flowline.length,
				heightposition = flowlines.height
			})
			flowline.length = getflowlinecontentlength(contentminsize)
			flowline.height = getflowlinecontentheight(contentminsize)
		end
	end
	if #flowline ~= 0 then
		table.insert(flowlines, flowline)
		flowlines.length = math.max(flowlines.length, flowline.length)
		if #flowlines > 1 then flowlines.height = flowlines.height + flowlineheightspacing end
		flowlines.height = flowlines.height + flowline.height

		flowline = nil
	end

	return flowlines
end