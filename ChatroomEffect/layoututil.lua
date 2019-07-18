local unicode = require("aegisub.unicode")
local regexutil = require("aegisub.re")
local util = require("aegisub.util")
local plugin = require("chatroomeffect.plugin")
require("chatroomeffect.util")

local layoututil = {}

local layoututil.preprocess_layout = function(layout_content, userdata)
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

--[[ 测算布局的最小尺寸。
---- 参数： layout, size, data
	layout: 当前处理的布局。
	size: 容纳布局的最大可用区域的尺寸。
	data: 一些必要的数据。
---- 返回： minsize
	minsize: 当前布局及所有子布局的最小需要尺寸。
--]]
local measure_minsize = function(layout, size, data)
	-- 获取布局的元数据。
	local meta = layoututil.parse_meta(layout, nil, size, data)
	
	-- 规划可用空间范围，若宽度或高度为auto，则使用可用的最大值。
	local avaliablerectsize = {
		width = nil,
		height = nil
	}
	if meta.width ~= nil then avaliablerectsize.width = meta.width
	elseif size.width == nil then avaliablerectsize.width = nil
	else avaliablerectsize.width = util.clamp(size.width - margin.left - margin.right, minwidth, maxwidth)
	end
	if meta.height ~= nil then avaliablerectsize.height = meta.height
	elseif size.height == nil then avaliablerectsize.height = nil
	else avaliablerectsize.height = height or util.clamp(size.height - margin.top - margin.bottom, minheight, maxheight)
	end
	
	local logic = plugin.logics[layout.layouttype or ""]
	if logic == nil then error("未定义类型为\""..(layout.layouttype or "").."\"的布局处理逻辑")
	else return logic.measure_minsize(layout, avaliablerectsize, meta, data)
	end
end

--[[ 进行布局。
---- 参数： layout, parentlayer, rect, data
	layout: 当前处理的布局。
	parentlayer: 当前处理的布局的父布局的层数。
	rect: 容纳布局的最大可用区域。
	data: 一些必要的数据。
---- 返回： result
	result: 当前布局及包含所有子布局的table。
--]]
local do_layout = function(layout, parentlayer, rect, data)
	-- 获取布局的元数据。
	local meta = layoututil.parse_meta(layout, parentlayer, rect, data)
	
	-- 规划可用空间范围，若宽度或高度为auto，则使用可用的最大值。
	local avaliablerect = {
		x = nil,
		y = nil,
		width = nil,
		height = nil
	}
	if meta.width ~= nil then avaliablerect.width = meta.width
	else avaliablerect.width = util.clamp(rect.width - meta.margin.left - meta.margin.right, minwidth, maxwidth)
	end
	if meta.height ~= nil then avaliablerect.height = meta.height
	else avaliablerect.height = height or util.clamp(rect.height - meta.margin.top - meta.margin.bottom, minheight, maxheight)
	end
	if horizontalalignment == "left" then
		avaliablerect.x = rect.x + meta.margin.left
	elseif horizontalalignment == "center" then
		avaliablerect.x = rect.x + (rect.width - (avaliablerect.width - meta.margin.left + meta.margin.right)) / 2
	elseif horizontalalignment == "right" then
		avaliablerect.x = rect.x + rect.width - (avaliablerect.width + meta.margin.right)
	end
	if verticalalignment == "top" then
		avaliablerect.y = rect.y + meta.margin.top
	elseif verticalalignment == "center" then
		avaliablerect.y = rect.y + (rect.height - (avaliablerect.height - meta.margin.top + meta.margin.bottom)) / 2
	elseif verticalalignment == "bottom" then
		avaliablerect.y = rect.y + rect.height - (avaliablerect.height + meta.margin.bottom)
	end
	
	local logic = plugin.logics[layout.layouttype or ""]
	if logic == nil then error("未定义类型为\""..(layout.layouttype or "").."\"的布局处理逻辑")
	else
		local result = logic.measure_minsize(layout, avaliablerect, meta, data)
		
		if result.rect.width < meta.minwidth then result.rect.width = meta.minwidth end
		if result.rect.height < meta.minheight then result.rect.height = meta.minheight end
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
		if (meta.maxwidth ~= nil and result.rect.width > meta.maxwidth) or
			(meta.maxheight ~= nil and result.rect.height > meta.maxheight) then
			local cliprect = {
				width = math.min(result.rect.width, meta.maxwidth),
				height = math.min(result.rect.height, meta.maxheight)
			}
			if meta.horizontalalignment == "left" then cliprect.x = result.rect.x
			elseif meta.horizontalalignment == "center" then cliprect.x = result.rect.x + (result.rect.width - cliprect.width) / 2
			elseif meta.horizontalalignment == "right" then cliprect.x = result.rect.x + result.rect.width - cliprect.width
			end
			if meta.verticalalignment == "top" then cliprect.y = result.rect.y
			elseif meta.verticalalignment == "center" then cliprect.y = result.rect.y + (result.rect.height - cliprect.height) / 2
			elseif meta.verticalalignment == "bottom" then cliprect.y = result.rect.y + result.rect.height - cliprect.height
			end
			result.clip:union(cliprect)
		end
		result.margin = meta.margin
		result.layer = meta.layer
		result.horizontalalignment = meta.horizontalalignment
		result.verticalalignment = meta.verticalalignment
		
		return result
	end
end

layoututil.parse_meta = function(layout, parentlayer, size, data)
	local meta = {}
	
	if tonumber(layout.layer) == "number" then meta.layer = math.floor(layout.layer)
	elseif layout.layer == nil then meta.layer = (parentlayer or 0) + 1
	else error("layer值的格式不正确。")
	end
	
	-- 计算margin。
	if layout.margin == nil then meta.margin = { left = 0, right = 0, top = 0, bottom = 0 }
	elseif tonumber(layout.margin) ~= nil then meta.margin = { left = tonumber(layout.margin), right = tonumber(layout.margin), top = tonumber(layout.margin), bottom = tonumber(layout.margin) }
	elseif type(layout.margin) == "string" then
		if util.trim(layout.margin) == "" then meta.margin = { left = 0, right = 0, top = 0, bottom = 0 }
		elseif regexutil.find("^\\s*(\\d*\\.\\d*|\\d+)(\\s*,\\s*(\\d*\\.\\d*|\\d+)){1,3}\\s*$", layout.margin) then
			regexresult = regexutil.find("(?:(^|,)\\s*)\\d*\\.\\d*|\\d+(?:\\s*($|,))", layout.margin)
			if #regexresult == 2 then
				meta.margin = {
					left = tonumber(regexresult[1].str),
					right = tonumber(regexresult[1].str),
					top = tonumber(regexresult[2].str),
					bottom = tonumber(regexresult[2].str)
				}
			elseif #regexresult == 4 then
				meta.margin = {
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
			meta.margin = {
				left = layout.margin.left or 0,
				right = layout.margin.right or 0,
				top = layout.margin.top or 0,
				bottom = layout.margin.bottom or 0
			}
		elseif #layout.margin == 2 then
			meta.margin = {
				left = layout.margin[1],
				right = layout.margin[1],
				top = layout.margin[2],
				bottom = layout.margin[2]
			}
		elseif #layout.margin == 4 then
			meta.margin = {
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
	if layout.minwidth == nil then meta.minwidth = 0
	elseif tonumber(layout.minwidth) ~= nil then
		meta.minwidth = tonumber(layout.minwidth)
		if meta.minwidth < 0 then log_error("minwidth值不应小于零。") end
	else log_error("minwidth值的格式不正确。")
	end
	if layout.maxwidth == nil then ;
	elseif tonumber(layout.maxwidth) ~= nil then
		meta.maxwidth = tonumber(layout.maxwidth)
		if meta.maxwidth < meta.minwidth then log_error("maxwidth值不应小于minwidth。") end
	else log_error("minwidth值的格式不正确。")
	end
	if layout.minheight == nil then meta.minheight = 0
	elseif tonumber(layout.minheight) ~= nil then
		meta.minheight = tonumber(layout.minheight)
		if meta.minheight < 0 then log_error("minheight值不应小于零。") end
	else log_error("minheight值的格式不正确。")
	end
	if layout.maxheight == nil then ;
	elseif tonumber(layout.maxheight) ~= nil then
		meta.maxheight = tonumber(layout.maxheight)
		if meta.maxheight < meta.minheight then log_error("maxheight值不应小于minheight。") end
	else log_error("minheight值的格式不正确。")
	end
	
	-- 计算宽度和高度。
	if tonumber(layout.width) == nil then -- 非数字类型值
		if unicode.to_lower_case(layout.width) == "fill" and size.width ~= nil then -- 填充
			meta.width = size.width - margin.left - margin.right
		elseif unicode.to_lower_case(layout.width) ~= "auto" then
			log_error("width值应为数值、fill或auto。")
		--else -- 自动
		end
	else -- 数字类型值
		meta.width = tonumber(layout.width)
		if meta.width < 0 then log_error("width值不应小于零。") end
	end
	if meta.width < meta.minwidth then meta.width = meta.minwidth
	elseif meta.maxwidth ~= nil and meta.width > meta.maxwidth then meta.width = meta.maxwidth
	end
	if tonumber(layout.height) == nil then -- 非数字类型值
		if unicode.to_lower_case(layout.height) == "fill" and size.height ~= nil then
			meta.height = size.height - margin.top - margint.bottom -- 填充
		elseif unicode.to_lower_case(layout.height) ~= "auto" then
			log_error("height值应为数值、fill或auto。")
		--else -- 自动
		end
	else -- 数字类型值
		meta.height = tonumber(layout.height)
		if meta.height < 0 then log_error("height值不应小于零。") end
	end
	if meta.height < meta.minheight then meta.height = meta.minheight
	elseif meta.maxheight ~= nil and meta.height > meta.maxheight then meta.height = meta.maxheight
	end
	-- 若宽度或高度为auto，具体数值需要根据不同布局分别计算得出，故此时为nil。
	
	-- 计算横向和纵向对齐。
	if layout.horizontalalignment == nil then meta.horizontalalignment = "left"
	elseif unicode.to_lower_case(layout.horizontalalignment) == "left" or
		unicode.to_lower_case(layout.horizontalalignment) == "center" or
		unicode.to_lower_case(layout.horizontalalignment) == "right" then
		meta.horizontalalignment = unicode.to_lower_case(layout.horizontalalignment)
	else log_error("horizontalalignment值的格式不正确。")
	end
	if layout.verticalalignment == nil then meta.verticalalignment = "top"
	elseif unicode.to_lower_case(layout.verticalalignment) == "top" or
		unicode.to_lower_case(layout.verticalalignment) == "center" or
		unicode.to_lower_case(layout.verticalalignment) == "bottom" then
		meta.verticalalignment = unicode.to_lower_case(layout.verticalalignment)
	else log_error("verticalalignment值的格式不正确。")
	end

	return meta
end
