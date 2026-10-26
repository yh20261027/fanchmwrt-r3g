local sys = require "luci.sys"

local m = Map("autoreboot", translate("自动重启"),
	translate("定时重启与断网自动守护。断网守护会持续检测网络连通性，连续失败达到阈值后先尝试重新拨号，仍失败则自动重启路由器。所有功能均可独立开关。"))

local s = m:section(NamedSection, "global", "global", translate("重启设置"))

--
-- 定时重启
--
local en = s:option(Flag, "schedule_enabled", translate("启用定时重启"),
	translate("每天在指定时间自动重启路由器"))
en.rmempty = false

local st = s:option(Value, "schedule_time", translate("重启时间"),
	translate("每天在此时间重启（24小时制 HH:MM）"))
st.placeholder = "04:30"
function st.validate(self, value)
	if value == nil or value == "" then
		return "04:30"
	end
	if value:match("^([01]?%d|2[0-3]):[0-5]%d$") then
		return value
	end
	return nil, translate("时间格式应为 HH:MM，例如 04:30")
end

--
-- 断网守护（watchdog）
--
local we = s:option(Flag, "watchdog_enabled", translate("启用断网自动重启"),
	translate("持续 ping 检测目标主机；连续失败达到阈值后自动重启"))
we.rmempty = false

local ci = s:option(Value, "check_interval", translate("检测间隔（秒）"),
	translate("每次检测之间的间隔"))
ci.placeholder = "30"
ci.datatype = "range(10,3600)"
ci.rmempty = false

local ft = s:option(Value, "fail_threshold", translate("连续失败次数阈值"),
	translate("阈值 × 检测间隔 = 断网多久后重启（默认 10 × 30秒 = 5分钟）"))
ft.placeholder = "10"
ft.datatype = "range(3,360)"
ft.rmempty = false

local ph = s:option(Value, "ping_hosts", translate("检测目标主机"),
	translate("多个主机用空格分隔，任一主机 ping 通即视为网络正常"))
ph.placeholder = "223.5.5.5 119.29.29.29"
ph.rmempty = false

local rec = s:option(Flag, "recover_enabled", translate("重启前先尝试重新拨号"),
	translate("达到阈值后先重新拨号 WAN 并等待，仍不通才重启（推荐开启，可避免大部分不必要的重启）"))
rec.rmempty = false

local rw = s:option(Value, "recover_wait", translate("重新拨号后等待时间（秒）"),
	translate("重新拨号后等待网络恢复的时间"))
rw.placeholder = "60"
rw.datatype = "range(10,600)"
rw.rmempty = false

--
-- 一键重启
--
local b = s:option(Button, "_reboot_now", translate("立即重启路由器"),
	translate("点击后路由器将在数秒后重启"))
b.inputstyle = "apply"
function b.write(self, section)
	sys.call("(/bin/sleep 3; /sbin/reboot) >/dev/null 2>&1 &")
end

function m.on_after_commit(self)
	sys.call("/etc/init.d/autoreboot restart >/dev/null 2>&1")
end

return m
