local file_handler = {}

function file_handler.read(file)
  local file_handle = io.input(file)
  local content = file_handle:read('a')
  print(content)
  file_handle:close()
end

return file_handler
