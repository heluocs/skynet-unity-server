#!/usr/bin/env lua
msgpack = require("msgpack.core")

local msgno = 1101
local msg = "hello skynet"
x = msgpack.unpack(msgpack.pack(msgno, msg))
print(x.msgno, x.msg)
