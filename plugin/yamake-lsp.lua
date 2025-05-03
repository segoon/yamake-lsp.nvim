local vim = vim

local function install()
  local path = os.getenv('HOME') .. '/.local/share/nvim/yamake-lsp'
  if vim.uv.fs_stat(path) then
    return
  end

  local arc_root = vim.system({'arc', 'root'}):wait().stdout
  arc_root = arc_root:sub(1, #arc_root-1)
  if not arc_root then
    return
  end

  local root = arc_root .. '/devtools/ide/vscode-yandex-arc/ya-make-lsp'
  local obj = vim.system({'npm', 'install'}, {cwd = root}):wait()
  if obj.code ~= 0 then
    error('npm install failed: ' .. obj.stderr)
    return
  end

  obj = vim.system({'npm', 'run', 'build'}, {cwd = root}):wait()
  if obj.code ~= 0 then
    error('npm run build failed: ' .. obj.stderr)
    return
  end

  obj = vim.system({'cp', '-r', 'out', path}, {cwd = root}):wait()
  if obj.code ~= 0 then
    error('cp -r failed: ' .. obj.stderr)
    return
  end
end

local function setup()
  vim.lsp.config['ya-make-lsp'] = {
    cmd = { 'node', os.getenv('HOME') .. '/.local/share/nvim/yamake-lsp/ya-make-lsp.js', '--stdio' },
    filetypes = { 'yamake' }
  }
  vim.lsp.enable('ya-make-lsp')
end


vim.api.nvim_create_autocmd({'BufReadPost'}, {
  pattern = 'ya.make',
  callback = install,
})

setup()

