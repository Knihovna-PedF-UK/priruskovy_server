kpse.set_program_name "luatex"
-- parse MARC XML
--
local domobject = require "luaxml-domobject"
local get_record = require "get_record"

local M = {}

-- table that links macr codes to field names
M.conversion_table = {
  ["245"] = {
    a = "title",
    b = "subtitle",
    c = "author"
  },
  ["260"] = {
    a = "place",
    b = "publisher",
    c = "year"
  }

}

local function clean_field(field)
  -- remove unnwanted characters at the end of the field
  return field:gsub("%s*[:/,]%s*$", "")
end
local function process_fields(entry, fields)
  -- convert numerical marc codes to the destination format
  -- get datafield@tag
  local tag = entry:get_attribute "tag"
  local conversion = M.conversion_table[tag]
  -- if this tag  is configured to be converted
  if conversion then
    for _, subfield in ipairs(entry:query_selector("subfield")) do
      local letter = subfield:get_attribute "code"
      local newfield = conversion[letter]
      if newfield then
        fields[newfield] = clean_field(subfield:get_text())
      end
    end
  end
  return fields
end

function M.process(xmlcode)
  local dom = domobject.parse(xmlcode)
  local fields = {}
  for _,entry in ipairs(dom:query_selector("datafield")) do
    fields = process_fields(entry, fields)
  end
  return fields
end





local result = get_record.query("f @attr 1=7  80-7178-888-0")
local fields = M.process(result)
for k,v in pairs(fields) do
  print(k,v)
end

