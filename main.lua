local luvi_version = '2.7.6'
local lit_version = '3.5.4'
local luvi_flavor = 'regular'

local uv = require('uv')
local luvi = require('luvi')

loadstring(luvi.bundle.readfile("luvit-loader.lua"), "bundle:luvit-loader.lua")()
local http = require('coro-http')

local arch = jit.arch == 'x64' and 'Windows-amd64' or 'Windows-ia32'

local luvi_url = 'https://github.com/luvit/luvi/releases/download/v%s/luvi-%s-%s.exe'
local lit_url = 'https://lit.luvit.io/packages/luvit/lit/v%s.zip'

luvi_url = string.format(luvi_url, luvi_version, luvi_flavor, arch)
lit_url = string.format(lit_url, lit_version)

local function download(url, file)
	print(string.format('Downloading %s to %s', url, file))
	local res, data = http.request('GET', url)
	if res.code < 300 then
		local f = assert(io.open(file, 'w'))
		f:write(data)
		f:close()
	else
		print(string.format('HTTP Error: %s - %s', res.code, res.reason))
		os.exit()
	end
end

coroutine.wrap(function()
	download(luvi_url, 'luvi.exe')
	download(lit_url, 'lit.zip')
	os.execute('luvi.exe lit.zip -- make lit.zip lit.exe luvi.exe')
	os.execute('del lit.zip')
	os.execute('lit.exe make lit://luvit/luvit luvit.exe luvi.exe')
end)()

uv.run()
