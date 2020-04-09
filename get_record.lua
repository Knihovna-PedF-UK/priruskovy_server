-- retrieve MARC XML file from z39.50 source
--
--
M = {}

local os = require "os"
local io = require "io"

local z39 = {
  server = "http://www.knihovny.cz",
  port   = "9000",
  database = "cpk_caslin"
}

-- commands that will be executed in yaz-client
-- querytype - enable prefix based syntax
-- %s placeholder for the query
-- s 1 - show first result
-- q - quit
local template = [[
querytype prefix
%s
s 1
q
]]

local function get_command(tmpname)
  return string.format("yaz-client -m %s %s:%s/%s", tmpname, z39.server, z39.port, z39.database)
end

local function get_script(query)
  return string.format(template, query)
end

-- change Z39.50 server
function M.set_library(server, port, database)
  z39.server = server or z39.server
  z39.port = port or z39.port
  z39.database = database or z39.database
end

-- change script that will be executed in the yaz-client
function M.set_script(script)
  template = script
end

-- run query on the server and retrieve data
function M.query(query)
  -- results will be placed to a temp file
  local tmpfile = os.tmpname()
  local command_name = get_command(tmpfile)
  local command = io.popen(command_name, "w")
  -- get script that will be executed in yaz-client
  local script = get_script(query)
  command:write(script)
  command:close()
  -- return result from the temp file and remove the file
  local f = io.open(tmpfile, "r")
  local result = f:read("*all")
  f:close()
  os.remove(tmpfile)
  return result
end

return M
