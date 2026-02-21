-- Copyright (C) 2018 dz <dingzhong110@gmail.com>
-- mod by 2021-2022  sirpdboy  <herboy2008@gmail.com> https://github.com/sirpdboy/luci-app-cupsd
-- mod by 2026-  xmprocat  <y6518@live.com> https://github.com/xmprocat/PrinterMgr

module("luci.controller.printermgr", package.seeall)

function index()
    -- if not nixio.fs.access("/etc/config/cupsd") and not nixio.fs.access("/etc/init.d/cupsd") and not nixio.fs.access("/usr/sbin/cupsd") then
    -- 	-- 如果系统既没有 cups 配置也没有 cupsd 二进制，仍然允许加载插件页面（可按需改为 return）
    -- end

    local page = entry({"admin", "services", "printermgr"},
        alias("admin", "services", "printermgr", "status"),
        _("Printer Manager"),
        60)
    page.dependent = true
    page.acl_depends = { "luci-app-PrinterMgr" }

    -- CBI 配置页（用于显示/修改 cupsd 设置）
    entry({"admin", "services", "printermgr", "basic"}, cbi("printermgr/basic"), _("Settings"), 10).leaf = true

    -- 状态面板（template + ajax）
    entry({"admin", "services", "printermgr", "status"}, template("printermgr_status"), _("Status"), 20).leaf = true

    -- Ajax / rpc endpoints
    entry({"admin", "services", "printermgr_status"}, call("act_status"))
    entry({"admin", "services", "printermgr_enable"}, call("act_enable"))
    entry({"admin", "services", "printermgr_disable"}, call("act_disable"))
end

-- 返回 JSON：cupsd 与 smbd 的安装/运行/init 脚本信息
function act_status()
    local sys  = require "luci.sys"
    local http = require "luci.http"
    local nixio = require "nixio"

    local function has_init(name)
        return nixio.fs.access("/etc/init.d/" .. name)
    end

    local e = { }
    e.cupsd = {
        installed = nixio.fs.access("/etc/config/cupsd") or nixio.fs.access("/usr/sbin/cupsd") or nixio.fs.access("/etc/init.d/cupsd"),
        running   = (sys.call("pidof cupsd > /dev/null") == 0),
        init_name = has_init("cupsd") and "cupsd" or nil
    }

    e.samba = {
        installed = nixio.fs.access("/etc/config/samba4") or nixio.fs.access("/usr/sbin/smbd") or (samba_init ~= nil),
        running   = (sys.call("pidof smbd > /dev/null") == 0) or (sys.call("pidof samba > /dev/null") == 0),
        init_name = has_init("samba4") and "samba4" or nil
    }

    http.prepare_content("application/json")
    http.write_json(e)
end

-- 启用服务：传入 service=cupsd 或 service=samba
function act_enable()
    local http = require "luci.http"
    local sys  = require "luci.sys"
    local nixio = require "nixio"

    local svc = http.formvalue("service") or ""
    local init = nil

    if svc == "cupsd" then
        if nixio.fs.access("/etc/init.d/cupsd") then init = "cupsd" end
    elseif svc == "samba" then
        if nixio.fs.access("/etc/init.d/samba4") then init = "samba4" end
    end

    local res = { service = svc, ok = false, msg = "" }
    if init then
        local ret = sys.call("/etc/init.d/"..init.." enable >/dev/null 2>&1")
        if ret == 0 then
            -- 可选：同时启动服务（注释掉则只做 enable）
            sys.call("/etc/init.d/"..init.." start >/dev/null 2>&1")
            res.ok = true
        else
            res.msg = "enable failed"
        end
    else
        res.msg = "no init script"
    end

    http.prepare_content("application/json")
    http.write_json(res)
end

-- 禁用服务
function act_disable()
    local http = require "luci.http"
    local sys  = require "luci.sys"
    local nixio = require "nixio"

    local svc = http.formvalue("service") or ""
    local init = nil

    if svc == "cupsd" then
        if nixio.fs.access("/etc/init.d/cupsd") then init = "cupsd" end
    elseif svc == "samba" then
        if nixio.fs.access("/etc/init.d/samba4") then init = "samba4" end
    end

    local res = { service = svc, ok = false, msg = "" }
    if init then
        local ret = sys.call("/etc/init.d/"..init.." disable >/dev/null 2>&1")
        -- 可选：同时停止服务
        sys.call("/etc/init.d/"..init.." stop >/dev/null 2>&1")
        if ret == 0 then res.ok = true else res.msg = "disable failed" end
    else
        res.msg = "no init script"
    end

    http.prepare_content("application/json")
    http.write_json(res)
end
