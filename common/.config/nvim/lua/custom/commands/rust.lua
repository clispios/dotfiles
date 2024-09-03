local M = {}

function M.cargoLeptosWatch()
  vim.cmd 'Cargo "leptos" "watch"'
  vim.cmd.wincmd 'L'
end

return M
