local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local socket = require "socket"
local message = require "message"
msgpack = require "msgpack.core"

local host

local CMD = {}
local client_fd

local function send_response(package)
	data = msgpack.unpack(package)
	print(" resp ok : ", data.msgno)
	socket.write(client_fd, netpack.pack(package))
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function(msg, sz)
		return skynet.tostring(msg, sz)
	end,
	dispatch = function(_, _, msg)
		print("------------client dispatch------------")
		data = msgpack.unpack(msg)
		module = data.msgno >> 16
		opcode = data.msgno & 0xffff

		local ok, result
		if module == message.MSG_LOGIN_MODULE >> 16 then
			ok, result = pcall(skynet.call, "loginserver", "lua", "dispatch", opcode, data.msg)
			if ok then
				send_response(result)
			else
				print("login error")
			end
		else
			print("server receive error msg")
		end
	end
}

function CMD.start(gate, fd, proto)
	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	print("---a client disconnect")
	skynet.exit()
end

skynet.start(function()
	print("---start agent---")
	skynet.dispatch("lua", function(session, source, cmd, ...)
		print("---agent cmd ", cmd)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
