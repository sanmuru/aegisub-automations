local animation = {}

animation.type = "fade"
animation.priority = 100

animation.to_tags = function(meta, tags, params)
	local times = {}
	local opacities = {}
	for i = 1, #params.times do
		if 
			(#params.times == i or (params.times[i] <= 0 and params.times[i + 1] > 0)) and -- 筛选掉字幕显示开始时间前的时间轴片段。
			(#params.duration == nil or
				(#times == 0 or (times[#times] < params.duration and params.times[i] >= params.duration))) and -- 筛选掉字幕显示结束时间后的时间轴片段。
			((#times == 0 or #params.times == i) or opacities[#opacities] ~= params.opacities[i]) then -- 筛选掉了一段透明度相同的时间轴片段上的三个时间点中处于中间的时间点。
			table.insert(times, params.times[i])
			table.insert(opacities, params.opacities[i])
		end
	end
	if #times == 0 then return {}
	elseif #times == 1 then
		local alpha = math.floor((100 - opacities[1]) / 100 * 255 + 0.5)
		return { {
			braces = true,
			value = {
				tagname = "fade",
				brackets = true,
				tagargs = {
					alpha, alpha, alpha,
					0, 0, 0
				}
			}
		} }
	elseif #times == 2 then
		local alpha1 = math.floor((100 - opacities[1]) / 100 * 255 + 0.5)
		local alpha2 = math.floor((100 - opacities[2]) / 100 * 255 + 0.5)
		return { {
			braces = true,
			value = {
				tagname = "fade",
				brackets = true,
				tagargs = {
					0, alpha1, alpha2,
					times[1], times[1], times[1], times[2]
				}
			}
		} }
	elseif #times == 3 then
		if params.duration ~= nil and
			(times[1] == 0 and times[4] == params.duration) and
			(opacities[1] == 0 and opacities[2] == 100 and opacities[3] == 0) then
			return { {
				braces = true,
				value = {
					tagname = "fad",
					brackets = true,
					tagargs = {
						times[2],
						times[3] - times[4]
					}
				}
			} }
		else
			local alpha1 = math.floor((100 - opacities[1]) / 100 * 255 + 0.5)
			local alpha2 = math.floor((100 - opacities[2]) / 100 * 255 + 0.5)
			local alpha3 = math.floor((100 - opacities[3]) / 100 * 255 + 0.5)
			return { {
				braces = true,
				value = {
					tagname = "fade",
					brackets = true,
					tagargs = {
						alpha1, alpha2, alpha3,
						times[1], times[2], times[2], times[3]
					}
				}
			} }
		end
	elseif #times == 4 and
		params.duration ~= nil and
			(times[1] == 0 and times[4] == params.duration) and
			(opacities[1] == 0 and opacities[2] == 100 and opacities[3] == 100 and opacities[3] == 0) then
		return { {
			braces = true,
			value = {
				tagname = "fad",
				brackets = true,
				tagargs = {
					times[2],
					times[4] - times[3]
				}
			}
		} }
	else
		local tags = {}
		for i = 1, #times do
			local time1, time2
			local opacity

			if i == 1 then
				time1 = math.min(0, times[1])
				time2 = time1
			else
				time1 = times[i - 1]
				time2 = times[i]
			end
			opacity = (meta.opacity / 100) * (opacity[i] / 100)
			
			local t_tag = {
				braces = true,
				value = {
					tagname = "t",
					brackets = true,
					tagargs = {
						time1, time2
					}
				}
			}

			for k, tn in ipairs({ "1a", "2a", "3a", "4a" }) do
				table.insert(t_tag.value.tagargs, {
					braces = false,
					value = {
						tagname = tn,
						tagargs = { _G.ass_alpha(meta[tn] * opacity) }
					}
				})
			end

			table.insert(tags, t_tag)
		end

		return tags
	end
end