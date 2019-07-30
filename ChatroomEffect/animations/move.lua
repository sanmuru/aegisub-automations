local animation = {}

animation.type = "move"
animation.priority = 100

animation.to_tags = function(meta, tags, params)
	if params.to ~= nil and params.to <= 0 then
		return { {
			braces = true,
			value = {
				tagname = "pos",
				brackets = true,
				tagargs = {
					meta.rect.x + (params.x2 or 0),
					meta.rect.y + (params.y2 or 0)
				}
			}
		} }
	elseif params.duration ~= nil and (params.from ~= nil and params.from >= params.duration) then
		return { {
			braces = true,
			value = {
				tagname = "pos",
				brackets = true,
				tagargs = {
					meta.rect.x + (params.x1 or 0),
					meta.rect.y + (params.y1 or 0)
				}
			}
		} }
	else
		local args = {
			meta.rect.x + (params.x1 or 0),
			meta.rect.y + (params.y1 or 0),
			meta.rect.x + (params.x2 or 0),
			meta.rect.y + (params.y2 or 0),
			params.from,
			params.to
		}
		if params.duration == nil then
			if params.to == nil then error("缺少必要参数值to。")
			elseif params.from == nil then args[5] = 0
			end
		else
			if params.to == nil then
				if params.from ~= nil then
					params[6] = params.duration
				end
			elseif params.from == nil then args[5] = 0
			end
		end
		return { {
			braces = true,
			value = {
				tagname = "move",
				brackets = true,
				tagargs = args
			}
		} }
	end
end