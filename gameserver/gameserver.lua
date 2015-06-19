local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local message = require "message"
msgpack = require "msgpack.core"

local CMD = {}
local protobuf = {}

function CMD.dispatch(opcode, msg)

end

skynet.start(function()
	print("---start game server---")
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)

	protobuf = require "protobuf"

	skynet.register "gameserver"
end)
