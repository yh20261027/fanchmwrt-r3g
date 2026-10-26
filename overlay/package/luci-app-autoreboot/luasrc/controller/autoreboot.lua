module("luci.controller.autoreboot", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/autoreboot") then
		return
	end

	entry({"admin", "system", "autoreboot"},
		cbi("autoreboot/settings"),
		_("自动重启"), 90)
end
