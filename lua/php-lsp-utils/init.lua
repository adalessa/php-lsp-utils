local phpactor = require "php-lsp-utils.phpactor"
local intelephense = require "php-lsp-utils.intelephense"

local servers = {
    phpactor = phpactor,
    intelephense = intelephense,
}

---@param server_name string
---@return table|nil, boolean
local get_client = function(server_name)
    local clients = vim.lsp.get_active_clients { name = server_name }
    local client = clients[1] or nil
    local new_instance = false

    if not client then
        local server = require("lspconfig")[server_name]
        local client_id = vim.lsp.start(server.make_config(vim.fn.getcwd()))
        if client_id == nil then
            return nil, false
        end
        client = vim.lsp.get_client_by_id(client_id)
        new_instance = true
    end

    return client, new_instance
end

---@param full_class string
---@param method string
local go_to = function(server_name, full_class, method)
    local server = servers[server_name]
    if server == nil then
        vim.notify("Server not valid", vim.log.levels.WARN, {})
        return
    end

    local client, is_new_instance = get_client(server_name)

    if not client then
        vim.notify("Can't get lsp client", vim.log.levels.WARN, {})
        return
    end

    return server.go_to(client, is_new_instance, full_class, method)
end

return {
    go_to = go_to,
}
