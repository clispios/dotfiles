vim.api.nvim_create_user_command('CargoLeptosWatch', require('custom.commands.rust').cargoLeptosWatch, {})

local function create_rust_test_module()
  -- Get current cursor position and indentation
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_indent = vim.fn.indent(cursor_line)
  local spacing = string.rep(' ', current_indent)

  -- Create the test snippet
  local test_snippet = {
    spacing .. '#[cfg(test)]',
    spacing .. 'mod tests {',
    spacing .. '    use super::*;',
    spacing .. '',
    spacing .. '    #[test]',
    spacing .. '    fn test_name() {',
    spacing .. '        todo!("Implement test");',
    spacing .. '    }',
    spacing .. '}',
    '',
  }

  -- Insert the snippet at current cursor position
  vim.api.nvim_buf_set_lines(0, cursor_line, cursor_line, false, test_snippet)

  -- Move cursor to the test name
  vim.api.nvim_win_set_cursor(0, { cursor_line + 6, string.len(spacing) + 8 })
end

local function create_tokio_test_module()
  -- Get current cursor position and indentation
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_indent = vim.fn.indent(cursor_line)
  local spacing = string.rep(' ', current_indent)

  -- Create the test snippet
  local test_snippet = {
    spacing .. '#[cfg(test)]',
    spacing .. 'mod tests {',
    spacing .. '    use super::*;',
    spacing .. '',
    spacing .. '    #[tokio::test]',
    spacing .. '    async fn test_name() -> Result<(), Box<dyn std::error::Error>> {',
    spacing .. '        todo!("Implement async test");',
    spacing .. '        Ok(())',
    spacing .. '    }',
    spacing .. '}',
    '',
  }

  -- Insert the snippet at current cursor position
  vim.api.nvim_buf_set_lines(0, cursor_line, cursor_line, false, test_snippet)

  -- Move cursor to the test name
  vim.api.nvim_win_set_cursor(0, { cursor_line + 6, string.len(spacing) + 8 })
end

-- Create user commands
vim.api.nvim_create_user_command('CreateRustTest', function()
  create_rust_test_module()
end, {})

vim.api.nvim_create_user_command('CreateTokioTest', function()
  create_tokio_test_module()
end, {})
