#!/usr/bin/env lua
pack = require("pack.core")

local msgno = 1101
local msg = "hello skynet"
x = pack.unpack(pack.pack(msgno, msg))
print(x.msgno, x.msg)
