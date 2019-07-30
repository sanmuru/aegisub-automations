local layoututil = require("chatroomeffect.layoututil")

local logic = {}

logic.type = "table"
logic.priority = 100

logic.measure_minsize = function(layout, size, meta, data)
	-- 获取布局的元数据。
	meta = parse_meta(layout, size, meta, data)
	
	local sizedtable = table_layout(meta, size)

	local minsize = {
		width = 0,
		height = 0
	}
	for _, rowheight in ipairs(sizedtable.rows) do minsize.height = minsize.height + rowheight end
	for _, columnwidth in ipairs(sizedtable.columns) do minsize.width = minsize.width + columnwidth end

	return minsize
end

logic.do_layout = function(layout, rect, meta, data, callback)
	-- 获取布局的元数据。
	meta = parse_meta(layout, size, meta, data)
	
	result = {
		layouttype = "table",
		rect = {
			x = nil,
			y = nil,
			width = size.width,
			height = size.height
		}
	}

	for _, content in ipairs(meta.layouts) do
		-- 计算子布局的可用范围。
		local contentavaliablerect = {
			x = rect.x,
			y = rect.y,
			width = 0,
			height = 0
		}
		for r = 1, content.row + content.rowspan - 1 do
			if r < content.row then
				contentavaliablerect.y = contentavaliablerect.y + sizedtable.rows[r]
			else
				contentavaliablerect.height = contentavaliablerect.height + sizedtable.rows[r]
			end
		end
		for c = 1, content.column + content.columnspan - 1 do
			if c < content.column then
				contentavaliablerect.x = contentavaliablerect.x + sizedtable.columns[c]
			else
				contentavaliablerect.width = contentavaliablerect.width + sizedtable.columns[c]
			end
		end

		-- 对子布局进行布局。
		local contentresult = layoututil.do_layout(content.layout, meta.layer, contentavaliablerect, data)

		table.insert(result, contentresult)
	end

	return result
end

local parse_meta = function(layout, size, data, meta)
	meta = util.copy(meta or {})

	-- 收集表中所有子布局的信息。
	meta.layouts = {}
	for _i, content in ipairs(layout) do
		local row, column, rowspan, columnspan
		row = tonumber(content["table$row"]) or 1
		if row < 1 then error("row应大于0。") end
		column = tonumber(content["table$column"]) or 1
		if row < 1 then error("column应大于0。") end
		rowspan = tonumber(content["table$rowspan"]) or 1
		if row < 1 then error("rowspan应大于0。") end
		columnspan = tonumber(content["table$columnspan"]) or 1
		if row < 1 then error("columnspan应大于0。") end
		
		table.insert(meta.layouts, {
			row = row,
			column = column,
			rowspan = rowspan,
			columnspan = columnspan,
			layout = content
		})
	end

	-- 计算所有行高。
	-- 显式定义的行高。
	if layout.rows == nil then meta.rows = {}
	elseif type(layout.rows) == "string" then
		if util.trim(layout.rows) == "" then
			meta.rows = {}
		elseif regexutil.find("^\\s*(auto|(\\d*\\.\\d*|\\d+)\\*?)?(\\s*,\\s*(auto|(\\d*\\.\\d*|\\d+)\\*?)*\\s*$", layout.rows) then
			meta.rows = {}
			regexresult = regexutil.find("(?:(^|,)\\s*)(auto|(\\d*\\.\\d*|\\d+)\\*?)(?:\\s*($|,))", layout.margin)
			for _, match in ipairs(regexresult) do
				local f, rowheight = tablelength_parse(row)
				if f then table.insert(meta.rows, rowheight)
				else log_error("rows值的格式不正确。")
				end
			end
		else log_error("rows值的格式不正确。")
		end
	elseif type(layout.rows) == "table" then
		meta.rows = {}
		for _, row in layout.rows do
			local f, rowheight = tablelength_parse(row)
			if f then table.insert(meta.rows, rowheight)
			else log_error("rows值的格式不正确。")
			end
		end
	else log_error("rows值的格式不正确。")
	end
	-- 隐式定义的行高。
	for _, l in ipairs(meta.layouts) do
		for i = 1, l.row + l.rowspan - 1 do
			if meta.rows[i] == nil then
				_, meta.rows[i] = tablelength_parse(nil)
			end
		end
	end

	-- 计算所有列宽。
	-- 显式定义的列宽。
	if layout.columns == nil then meta.columns = {}
	elseif type(layout.columns) == "string" then
		if util.trim(layout.columns) == "" then
			meta.columns = {}
		elseif regexutil.find("^\\s*(auto|(\\d*\\.\\d*|\\d+)\\*?)?(\\s*,\\s*(auto|(\\d*\\.\\d*|\\d+)\\*?)*\\s*$", layout.columns) then
			meta.columns = {}
			regexresult = regexutil.find("(?:(^|,)\\s*)(auto|(\\d*\\.\\d*|\\d+)\\*?)(?:\\s*($|,))", layout.margin)
			for _, match in ipairs(regexresult) do
				local f, columnheight = tablelength_parse(column)
				if f then table.insert(meta.columns, columnheight)
				else log_error("columns值的格式不正确。")
				end
			end
		else log_error("columns值的格式不正确。")
		end
	elseif type(layout.columns) == "table" then
		meta.columns = {}
		for _, column in layout.columns do
			local f, columnheight = tablelength_parse(column)
			if f then table.insert(meta.columns, columnheight)
			else log_error("columns值的格式不正确。")
			end
		end
	else log_error("columns值的格式不正确。")
	end
	-- 隐式定义的列宽。
	for _, l in ipairs(meta.layouts) do
		for i = 1, l.column + l.columnspan - 1 do
			if meta.columns[i] == nil then
				_, meta.columns[i] = tablelength_parse(nil)
			end
		end
	end
	
	return meta
end

local tablelength_parse = function(length)
	if length == nil then
		return true, { type = "weight", value = 1 }
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
				if tonumber(length.value) == 0 then return true, { type = "pixel", value = 0 }
				else return true, { type = "weight", value = tonumber(length.value) }
				end
			end
		end
	end
			
	return false
end

--[[ 进行表式布局。
---- 参数： meta, size, text
	meta: 解释布局得到的元数据。
	size: 用于布局的预留范围。
---- 返回： tablelengthinfo
	sizedtable: 确定表格的所有行的高度和列的宽度。
--]]
local table_layout = function(meta, size)
	local layouttable = {}
	local sizedtable = { rows = {}, columns = {} }

	for _, content in meta.layouts do
		-- 将行高和列宽分类为像素、自动、权重三类。
		local rowpixels, columnpixels = { total = 0 }, { total = 0 }
		local rowautos, columnautos = { total = 0 }, { total = 0 }
		local rowweights, columnweights = { total = 0 }, { total = 0 }

		for r = content.row, content.row + content.rowspan - 1 do
			local row = meta.rows[r]
			if row.type == "pixel" then
				table.insert(rowpixels, { row = r, value = row.value })
				rowpixels.total = rowpixels.total + row.value
			elseif row.type == "auto" then
				table.insert(rowautos, r)
				rowautos.total = rowautos.total + 1
			elseif row.type == "weight" then
				table.insert(rowweights, { row = r, value = row.value })
				rowweights.total = rowweights.total + row.value
			end
		end
		for c = content.column, content.column + content.columnspan - 1 do
			local column = meta.columns[c]
			if column.type == "pixel" then
				table.insert(columnpixels, { column = c, value = column.value })
				columnpixels.total = columnpixels.total + column.value
			elseif column.type == "auto" then
				table.insert(columnautos, c)
				columnautos.total = columnautos.total + 1
			elseif column.type == "weight" then
				table.insert(columnweights, { column = c, value = column.value })
				columnweights.total = columnweights.total + column.value
			end
		end

		-- 定义可用范围尺寸。
		local contentavaliablerectsize = {
			width = nil,
			height = nil
		}
		if #rowautos == 0 and #rowweights == 0 then contentavaliablerectsize.height = rowpixels end
		if #columnautos == 0 and #columnweights == 0 then contentavaliablerectsize.width = columnpixels end

		-- 计算最小尺寸。
		contentminsize = layoututil.measure_minsize(content.layout, contentavaliablerectsize, data)
		-- 将最小尺寸保存入content表，以作后续计算时的参考。
		content.minsize = contentminsize
		
		--[[
			使用每个子布局的最小尺寸对行高和列宽进行分配，最后取所有分配值的最大值。
			将每次分配的值储存在列表中，以便后续处理。
		--]]

		-- 使用最小尺寸对行高进行初步分配，主要针对多个单元格合并后的大单元格。
		if #rowpixels ~= 0 then for _, ri in ipairs(rowpixels) do sizedtable.rows[ri.row] = ri.value end end
		if contentminsize.height > rowpixels.total then
			local rl = contentminsize.height - rowpixels.total
			if #rowweights ~= 0 then
				for _, ri in ipairs(rowweights) do
					if sizedtable.rows[ri.row] == nil then sizedtable.rows[ri.row] = {} end
					table.insert(sizedtable.rows[ri.row], rl / rowweights.total * ri.value)
				end
			elseif #rowautos ~= 0 then
				for _, ri in ipairs(rowautos) do
					if sizedtable.rows[ri.row] == nil then sizedtable.rows[ri.row] = {} end
					table.insert(sizedtable.rows[ri.row], rl / #rowautos)
				end
			end
		end
		
		-- 使用最小尺寸对列宽进行初步分配，主要针对多个单元格合并后的大单元格。
		if #columnpixels ~= 0 then for _, ci in ipairs(columnpixels) do sizedtable.rows[ci.column] = ci.value end end
		if contentminsize.height > columnpixels.total then
			local cl = contentminsize.height - columnpixels.total
			if #columnweights ~= 0 then
				for _, ci in ipairs(columnweights) do
					if sizedtable.columns[ci.column] == nil then sizedtable.columns[ci.column] = {} end
					table.insert(sizedtable.columns[ci.column], cl / columnweights.total * ci.value)
				end
			elseif #columnautos ~= 0 then
				for _, ci in ipairs(columnautos) do
					if sizedtable.columns[ci.column] == nil then sizedtable.columns[ci.column] = {} end
					table.insert(sizedtable.columns[ci.column], cl / #columnautos)
				end
			end
		end
	end

	-- 计算所有行高的分配值的最大值。
	for r, rh in ipairs(sizedtable.rows) do
		if type(rh) == "table" then -- 有一个或多个分配值。
			if #rh <= 1 then sizedtable[r] = nil
			else
				local max = 0
				for _, rhv in ipairs(rh) do max = math.max(max, rhv) end
				sizedtable[r] = max
			end
		end
	end
	-- 计算所有列宽的分配值的最大值。
	for c, ch in ipairs(sizedtable.columns) do
		if type(ch) == "table" then -- 有一个或多个分配值。
			if #ch <= 1 then sizedtable[c] = nil
			else
				local max = 0
				for _, rhv in ipairs(ch) do max = math.max(max, rhv) end
				sizedtable[c] = max
			end
		end
	end
	
	--[[
		此时仍可能存在值为nil的行高和列宽，nil表示分配值为0或自动和权重类型的分配值仅有一个，应重新计算以优化。
	--]]

	-- 重新计算值为nil的行高和列宽。
	for _, content in meta.layouts do
		-- 将行高和列宽分类为像素、自动、权重三类。
		local rowpixels, columnpixels = 0, 0
		local rowautos, columnautos = { total = 0 }, { total = 0 }
		local rowweights, columnweights = { total = 0 }, { total = 0 }

		for r = content.row, content.row + content.rowspan - 1 do
			if sizedtable.rows[r] == nil then
				local row = meta.columns[r]
				if row.type == "auto" then
					table.insert(rowautos, r)
					rowautos.total = rowautos.total + 1
				elseif row.type == "weight" then
					table.insert(rowweights, { row = r, value = row.value })
					rowweights.total = rowweights.total + row.value
				end
			else
				rowpixels = rowpixels + sizedtable.rows[r]
			end
		end
		for c = content.column, content.column + content.columnspan - 1 do
			if sizedtable.columns[c] == nil then
				local column = meta.columns[c]
				if column.type == "auto" then
					table.insert(columnautos, c)
					columnautos.total = columnautos.total + 1
				elseif column.type == "weight" then
					table.insert(columnweights, { column = c, value = column.value })
					columnweights.total = columnweights.total + column.value
				end
			else
				columnpixels = columnpixels + sizedtable.columns[c]
			end
		end

		-- 使用最小尺寸对行高进行再次分配，主要针对多个单元格合并后的大单元格。
		if content.minsize.height > rowpixels then
			local rl = content.minsize.height - rowpixels
			if #rowweights ~= 0 then
				for _, ri in ipairs(rowweights) do
					sizedtable.rows[ri.row] = rl / rowweights.total * ri.value
				end
			elseif #rowautos ~= 0 then
				for _, ri in ipairs(rowautos) do
					sizedtable.rows[ri.row] = rl / #rowautos
				end
			end
		end
		
		-- 使用最小尺寸对列宽进行再次分配，主要针对多个单元格合并后的大单元格。
		if content.minsize.height > columnpixels then
			local cl = content.minsize.height - columnpixels
			if #columnweights ~= 0 then
				for _, ci in ipairs(columnweights) do
					sizedtable.columns[ci.column] = cl / columnweights * ci.value
				end
			elseif #columnautos ~= 0 then
				for _, ci in ipairs(columnautos) do
					sizedtable.columns[ci.column] = cl / #columnautos
				end
			end
		end
	end
	
	--[[
		此时仍可能存在值为nil的行高和列宽，nil表示分配值为0。
	--]]

	for r, rh in ipairs(sizedtable.rows) do if rh == nil then sizedtable.rows[r] = 0 end end
	for c, ch in ipairs(sizedtable.columns) do if ch == nil then sizedtable.columns[c] = 0 end end

	-- 收集所有权重类型的行高和列宽。
	local rowpixels, columnpixels = 0, 0
	local rowweights, columnweights = { total = 0 }, { total = 0 }
	for r, row in ipairs[meta.rows] do
		if row.type == "weight" then
			table.insert(rowweights, { row = r, value = row.value, length = sizedtable.rows[r] })
			rowweights.total = rowweights.total + row.value
		else
			rowpixels = rowpixels + sizedtable.rows[r]
		end
	end
	for c, column in ipairs[meta.columns] do
		if column.type == "weight" then
			table.insert(columnweights, { column = c, value = column.value, length = sizedtable.columns[c] })
			columnweights.total = columnweights.total + column.value
		else
			columnpixels = columnpixels + sizedtable.columns[c]
		end
	end

	-- 根据权重对行高和列宽进行最终分配。
	if size.width == nil then -- 自动宽度
		-- 计算比例的最大值。
		local scale = 0
		for c, cw in ipairs(columnweights) do scale = math.max(scale, cw.length / cw.value) end
		-- 根据权重和比例计算列宽。
		for c, cw in ipairs(columnweights) do sizedtable.columns[c] = scale * cw.value end
	else -- 指定宽度
		-- 计算权重类列宽总和。
		local length = math.max(0, size.width - columnpixels)
		-- 根据权重和权重总和计算列宽。
		for c, cw in ipairs(columnweights) do sizedtable.columns[c] = length / columnweights.total * cw.value end
	end
	if size.width == nil then -- 自动高度
		-- 计算比例的最大值。
		local scale = 0
		for r, rw in ipairs(rowweights) do scale = math.max(scale, rw.length / rw.value) end
		-- 根据权重和比例计算行高。
		for r, rw in ipairs(rowweights) do sizedtable.rows[r] = scale * rw.value end
	else -- 指定高度
		-- 计算权重类行高总和。
		local length = math.max(0, size.width - rowpixels)
		-- 根据权重和权重总和计算行高。
		for r, rw in ipairs(rowweights) do sizedtable.rows[r] = length / rowweights.total * rw.value end
	end

	return sizedtable
end