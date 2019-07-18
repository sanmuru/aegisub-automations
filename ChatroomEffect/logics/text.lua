local logic = {}

logic.type = "text"
logic.priority = 100

logic.measure_minsize = function(layout, size, meta, data)
	-- 获取布局的元数据。
	meta = parse_meta(layout, size, meta, data)
	
	-- 进行文本布局。
	local wrappedtextminsize, wrappedtext = text_layout(meta, size)
	
	return wrappedtextminsize
end

logic.do_layout = function(layout, rect, meta, data)
	-- 获取布局的元数据。
	meta = parse_meta(layout, size, meta, data)
	
	-- 进行文本布局。
	local wrappedtextminsize, wrappedtext = text_layout(meta, size)
	
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
	
	return result
end

local parse_meta = function(layout, size, data, meta)
	meta = util.copy(meta or {})
	
	-- 获取文本使用的样式。
	meta.style = style_parse(data.styles, layout.style)

	-- 计算文本换行方式
	if layout.wordwrap == nil then meta.wordwrap = "none"
	elseif unicode.to_lower_case(layout.wordwrap) == "none" or
		unicode.to_lower_case(layout.wordwrap) == "hard" or
		unicode.to_lower_case(layout.wordwrap) == "soft" then
		meta.wordwrap = unicode.to_lower_case(layout.wordwrap)
	else log_error("wordwrap值的格式不正确。")
	end
	
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
	
	-- 获取文本。
	if type(layout.text) == string then metatext = layout.text
	else metatext = ""
	end
	
	return meta
end

--[[ 进行文本布局
---- 参数： meta, size, text
	meta: 解释布局得到的元数据。
	size: 用于布局的预留范围。
	text: 需要测算的文本，若为nil时则取meta.text。
---- 返回： minsize, wrappedtext
	 minsize: 布局后文本占用的矩形的最小范围。
	 wrappedtext: 布局后的文本。
--]]
local text_layout = function(meta, size, text)
	text = text or meta.text

	local rawlines = regexutil.split(text, "\\r?\\n")
	local linebuffer = { length = 0 }
	for _, rawline in ipairs(rawlines) do
		if rawline == "" then -- 若为空行，则高度为样式的字体大小的一半。
			table.insert(linebuffer, rawline)
			linebuffer.height = linebuffer.height + meta.style.fontsize / 2
		else
			if meta.wordwrap == "none" then -- 不换行
				table.insert(linebuffer, rawline)
				local w, h, d, el = aegisub.text_extents(meta.style, rawline)
				linebuffer.length = math.max(linebuffer.length, w)
				linebuffer.height = linebuffer.height + h
			else
				regexresult = regexutil.match("\\s+(?=\\S|$)|[\\dA-Za-z]+(?=[^\\dA-Za-z]|$)|\\b.+?\\b|\\S+(?=\\s|$)", rawline)
				
				local spanbuffer = {}
				for _, match in ipairs(regexresult) do
					local wrappable
					if meta.wordwrap == "hard" then -- 硬换行
						wrappable = true -- 所有文本段均能逐字换行。
					elseif meta.wordwrap == "soft" then -- 软换行
						if regexutil.find("^(\\s+|[\\dA-Za-z]+)$", match.str) then wrappable = false -- 仅数字和字母相连的组合不能逐字换行。
						else wrappable = true -- 其余组合均能逐字换行。
						end
					end
					
					table.insert(spanbuffer, match.str)
					while true do
						local w, h, d, el = aegisub.text_extents(meta.style, table.concat(spanbuffer))
						if size.width == nil or w <= size.width then break
						elseif wrappable or #spanbuffer == 1 then
							table.remove(spanbuffer, #spanbuffer)
							
							for c in unicode.chars(match.str) do
								table.insert(spanbuffer, c)
								local w, h, d, el = aegisub.text_extents(meta.style, table.concat(spanbuffer))
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
