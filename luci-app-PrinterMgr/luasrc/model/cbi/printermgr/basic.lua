-- Copyright 2008 Yanira <forum-2008@email.de>
-- Licensed to the public under the Apache License 2.0.
-- mod by wulishui 20191205
-- mod by 2021-2022  sirpdboy  <herboy2008@gmail.com> https://github.com/sirpdboy/luci-app-cupsd
-- mod by 2026-  xmprocat  <y6518@live.com> https://github.com/xmprocat/PrinterMgr

local m = Map("cupsd", translate("Printer Manager"))
m.description = translate("Printer Manager is used to manage the CUPS printing service and Samba printing/sharing service.")

local s = m:section(TypedSection, "cupsd", translate("CUPS - Global Settings"))
s.addremove = false
s.anonymous = true

local o = s:option(Flag, "enabled", translate("Enable CUPS"))
o.default = 0

o = s:option(Value, "port",
    translate("Web Management Port"),
    translate("You can set any unused port. It does not affect the internal operation of CUPS.")
)
o.datatype = "uinteger"
o.default = 631
o:depends("enabled", "1")

return m


