local debug = require("lsp-debug-tools")

local function filter_by(expected)
    return function(bufnr)
        if #expected == 0 then
            return true
        end

        local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype");
        local found = false
        for i = 1, #expected do
            if filetype == expected[i] then
                found = true
                break
            end
        end

        return found
    end
end

local id = nil
local filter = filter_by({})
local config = nil


local function attach_lsp(args)
    if id == nil then
        return
    end

    local bufnr = args.buffer or args.buf;
    if not bufnr or not filter(bufnr) then
        return;
    end

    if not vim.lsp.buf_is_attached(args.buffer, id) then
        vim.lsp.buf_attach_client(args.buffer, id);
    end
end

vim.api.nvim_create_autocmd("BufNew", {
    callback = attach_lsp
});

vim.api.nvim_create_autocmd("BufEnter", {
    callback = attach_lsp,
});

local function start(opts)
    if id ~= nil then
        return
    end

    config = vim.tbl_deep_extend("force", {}, {
        expected = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        name = "jsperf-lsp",
        cmd = { "jsperf-lsp", "--level", "DEBUG" },
        root_dir = vim.fs.dirname(
        vim.fs.find({ "package.json" }, { upward = true })[1]
        )
    }, opts or {})

    id = vim.lsp.start_client({
        name = opts.name,
        cmd = opts.cmd,
        root_dir = opts.root_dir,
        handlers = opts.handlers,
    })

    filter = filter_by(config.expected)

    local bufnr = vim.api.nvim_get_current_buf()

    print("lsp attaching...")
    attach_lsp({ buffer = bufnr })
    print("lsp attached")
end

local function stop()
    if id == nil then
        return
    end

    vim.lsp.stop_client(id)
    id = nil
end

function restart_java_lsp()
    stop();

    start({
        expected = {},
        name = "java-lsp",
        cmd = {
            "/home/henrique/repositorios/java-language-server/dist/java_lsp",
        },
        root_dir = vim.loop.cwd(), 
        handlers = {
            ["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics,
            { virtual_text = false, signs = true, update_in_insert = false, underline = true}
            ),
        }
    });
end
