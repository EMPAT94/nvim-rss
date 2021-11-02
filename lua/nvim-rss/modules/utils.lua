local UTILS = {}

function UTILS.sanitize(text)
  if (not text) then return end
  local str = tostring(text):gsub("<.->", "") -- Remove markup
  local t = {}
  for s in string.gmatch(str, "([^\n]+)") do t[#t + 1] = s end
  return t
end

function UTILS.is_url(str)
  local starts_with_http = str:sub(1, 4) == "http"
  local has_no_spaces = not str:match("%s")
  return starts_with_http and has_no_spaces
end

return UTILS
