local logic = {}

logic.type = "stack"
logic.priority = 100

logic.measure_minsize = function(layout, size, meta, data)
	-- 获取布局的元数据。
	meta = parse_meta(layout, size, meta, data)
	
	local contentavaliablerectsize
	if meta.orientation == "down" or meta.orientation == "up" then
		contentavaliablerectsize = {
			width = size.width,
			height = nil
		}
	elseif meta.orientation == "right" or meta.orientation == "left" then
		contentavaliablerectsize = {
			width = nil,
			height = size.height
		}
	end
	local maxwidth, maxheight = 0, 0
	for index, contentlayout in ipairs(layout) do
		local contentminsize = layoututil.measure_minsize(contentlayout, contentavaliablerectsize, data)
		if meta.orientation == "down" or meta.orientation == "up" then
			maxwidth = math.max(maxwidth, contentminsize.width)
			maxheight = maxheight + contentminsize.height
		elseif meta.orientation == "right" or meta.orientation == "left" then
			maxwidth = maxwidth + contentminsize.width
			maxheight = math.max(maxheight, contentminsize.height)
		end
	end
	
	return {
		width = size.width or maxwidth,
		height = size.height or maxheight
	}
end

logic.do_layout = function(layout, rect, meta, data, callback)
	-- 获取布局的元数据。
	meta = parse_meta(layout, size, meta, data)
	
	local contentavaliablerectsize
	if meta.orientation == "down" or meta.orientation == "up" then
		contentavaliablerectsize = {
			width = size.width,
			height = nil
		}
	elseif meta.orientation == "right" or meta.orientation == "left" then
		contentavaliablerectsize = {
			width = nil,
			height = size.height
		}
	end
	local maxlength = 0
	for index, contentlayout in ipairs(layout) do
		local contentminsize = layoututil.measure_minsize(contentlayout, contentavaliablerectsize, data)
		local contentavaliablerect = {
			x = nil,
			y = nil,
			width = math.max(contentavaliablerectsize.width or contentminsize.width, contentminsize.width),
			height = math.max(contentavaliablerectsize.height or contentminsize.height, contentminsize.height)
		}
		local contentresult = layoututil.do_layout(contentlayer, meta.layer, contentavaliablerect, data)
		if meta.orientation == "down" or meta.orientation == "up" then
			maxwidth = math.max(maxwidth, contentminsize.width)
			maxheight = maxheight + contentminsize.height
		elseif meta.orientation == "right" or meta.orientation == "left" then
			maxwidth = maxwidth + contentminsize.width
			maxheight = math.max(maxheight, contentminsize.height)
		end
	end
	
	for index, contentlayout in ipairs(layout) do
		local contentminsize = layout.measure_minsize(contentlayout, contentavaliablerect, data)
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
end

local parse_meta = function(layout, size, data, meta)
	meta = util.copy(meta or {})

	-- 计算布局方向。
	if layout.orientation == nil then meta.orientation = "down"
	elseif unicode.to_lower_case(layout.orientation) == "down" or
		unicode.to_lower_case(layout.orientation) == "right" or
		unicode.to_lower_case(layout.orientation) == "up" or
		unicode.to_lower_case(layout.orientation) == "left" then
		meta.orientation = unicode.to_lower_case(layout.orientation)
	else log_error("orientation值的格式不正确。")
	end
	
	return meta
end