local regexutil = require("aegisub.re")
require("chatroomeffect.util")

local shape = {}

shape.type = { "", "path" }
shape.priority = 100

local shape.parse = function(s)
	if s == nil then return nil
	elseif s == "string" then
		local reader = {
			position = 1,
			chunks = regexutil.split(s, "\\s+", true),
			peek = function(self)
				if #chunks < position then return nil
				elseif tonumber(self.chunks[self.position]) then return "number", tonumber(self.chunks[self.position])
				else
					local cmd = self.chunks[self.position]
					if cmd == "m" or cmd == "n" or cmd == "l" or cmd == "b" or cmd == "s" or cmd == "p" or cmd == "c" then
						return "command", cmd
					end
				end
				log_error("»æ»­Ö¸Áî¸ñÊ½´íÎó¡£")
			end,
			read = function(self, type)
				local t, v = self:peek()
				if type == nil or t == type then
					self.position = self.position + 1
					return t, v
				else error("»æ»­Ö¸Áî¸ñÊ½´íÎó¡£")
				end
			end
		}
		
		local path = {}
		while reader:peek() do
			local cmd = reader:read("command")
			if cmd == "m" or cmd == "n" or cmd == "l" or cmd == "p" then
				return { command = cmd, [1] = { x = reader:read("number"), y = reader:read("number") } }
			elseif cmd == "b" then
				return {
					command = cmd,
					[1] = { x = reader:read("number"), y = reader:read("number") },
					[2] = { x = reader:read("number"), y = reader:read("number") },
					[3] = { x = reader:read("number"), y = reader:read("number") },
				}
			elseif cmd == "s" then
				local segment = { command = cmd }
				while reader:peek() == "number" do
					table.insert(segment, { x = reader:read("number"), y = reader:read("number") })
				end
			elseif cmd == "c" then
				return { command = cmd }
			end
		end
		path.getcommand = function(self)
			local cmdstr = ""
			local flag = true
			for _, segment in ipairs(self) do
				if flag then flag = false
				else cmdstr = cmdstr.." "
				end
				
				cmdstr = cmdstr..segment.cmd
				for _, point in ipairs(segment) do
					cmdstr = string.format("%s %d %d", cmdstr, point.x, point.y)
				end
			end
		end
		
		return path
	end
end