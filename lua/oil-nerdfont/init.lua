local M = {}

--- @class Option
--- @field highlight table | nil
--- @field highlight.directory string | nil Highlight group name for directory icon. default: "OilDirIcon"
--- @field highlight.file string | nil Highlight group name for file icon. default: nil

--- @type Option
local default_option = {
	highlight = {
		directory = "OilDirIcon",
		file = nil,
	},
}

--- Integrate oil.nvim with lambdalisue/vim-nerdfont
--- @param opt Option | nil option
M.setup = function(opt)
	local constants = require("oil.constants")
	local merged = vim.tbl_deep_extend("force", default_option, opt or {})
	require("oil.columns").register("icon", {
		render = function(entry)
			local field_type = entry[constants.FIELD_TYPE]
			local filename = entry[constants.FIELD_NAME]
			local meta = entry[constants.FIELD_META]
			if field_type == "link" and meta then
				if meta.link then
					filename = meta.link
				end
				if meta.link_stat then
					field_type = meta.link_stat.type
				end
			end
			if field_type == "directory" then
				local icon = vim.fn["nerdfont#directory#find"]()
				return { icon, merged.highlight.directory }
			end
			if meta and meta.display_name then
				filename = meta.display_name
			end
			local icon = vim.fn["nerdfont#find"](filename)
			return { icon, merged.highlight.file }
		end,
		parse = function(line)
			return line:match("^(%S+)%s+(.*)$")
		end,
	})
end

return M
