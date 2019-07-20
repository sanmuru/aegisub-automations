local layoututil = require("chatroomeffect.layoututil")

local logic = {}

logic.type = "stack"
logic.priority = 100

logic.measure_minsize = function(layout, size, meta, data)
	-- 获取布局的元数据。
	meta = parse_meta(layout, size, meta, data)
	
	local stackline = stack_layout(meta, size)

	if meta.orientation == "down" or meta.orientation == "up" then
		return {
			width = size.width or stackline.width,
			height = size.height or stackline.length
		}
	elseif meta.orientation == "right" or meta.orientation == "left" then
		return {
			width = size.width or stackline.length,
			height = size.height or stackline.width
		}
	end
end

logic.do_layout = function(layout, rect, meta, data, callback)
	-- 获取布局的元数据。
	meta = parse_meta(layout, size, meta, data)
	
	local stackline = stack_layout(meta, size)

	result = {
		layouttype = "stack",
		rect = {
			x = nil,
			y = nil,
			width = size.width,
			height = size.height
		}
	}

	for _, content in ipairs(stackline) do
		local contentrect
		if layout.orientation == "down" then
			local contentrect = {
				x = rect.x,
				y = rect.y + content.position,
				width = stackline.width,
				height = content.length
			}
			contentresult = layoututil.do_layout(contentlayout, meta.layer, contentrect, data)
		elseif layout.orientation == "up" then
			local contentrect = {
				x = rect.x,
				y = rect.y + rect.height - content.position - stackline.length,
				width = stackline.width,
				height = content.length
			}
			contentresult = layoututil.do_layout(contentlayout, meta.layer, contentrect, data)
		elseif layout.orientation == "right" then
			local contentrect = {
				x = rect.x + content.position,
				y = rect.y,
				width = content.length,
				height = stackline.width
			}
			contentresult = layoututil.do_layout(contentlayout, meta.layer, contentrect, data)
		elseif layout.orientation == "left" then
			local contentrect = {
				x = rect.x + rect.width - content.position - stackline.length,
				y = rect.y,
				width = content.length,
				height = stackline.width
			}
			contentresult = layoututil.do_layout(contentlayout, meta.layer, contentrect, data)
		end
		table.insert(result, contentresult)
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

local stack_layout = function(meta, size)
	local stackline = {}
	
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
	
	stackline.length = 0
	stackline.width = 0
	for index, contentlayout in ipairs(layout) do
		local contentminsize = layoututil.measure_minsize(contentlayout, contentavaliablerectsize, data)
		if meta.orientation == "down" or meta.orientation == "up" then
			table.insert(stackline, { position = stackline.length, layout = contentlayout, length = contentminsize.height })
			stackline.width = math.max(stackline.width, contentminsize.width)
			stackline.length = stackline.length + contentminsize.height
		elseif meta.orientation == "right" or meta.orientation == "left" then
			table.insert(stackline, { position = stackline.length, layout = contentlayout, length = contentminsize.width })
			stackline.length = stackline.length + contentminsize.width
			stackline.width = math.max(stackline.width, contentminsize.height)
		end
	end
end