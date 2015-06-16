local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local message = require "message"

msgpack = require("msgpack.core")

local CMD = {}
local protobuf = {}

local function processAccountLoginRequest(msg)
	print("---process login---")
	local data = protobuf.decode("CMsgAccountLoginRequest", msg)
	local account = data.account
	print("----account:" , account)

	local tb = {}
	tb.accountid = 1101

	local msgbody =  protobuf.encode("CMsgAccountLoginResponse", tb)
	return msgpack.pack(message.MSG_ACCOUNT_LOGIN_RESPONSE_S2C, msgbody)
end

local function processAccountRegistRequest(msg)
	print("---process regist---")
	return nil
end

function CMD.dispatch(opcode, msg)
	print("login dispatch msgno " .. opcode)
	if opcode == message.MSG_ACCOUNT_LOGIN_REQUEST_C2S & 0x0000FFFF then
		return processAccountLoginRequest(msg)
	elseif opcode == message.MSG_ACCOUNT_REGIST_RESPONSE_C2S & 0x0000FFFF then
		return processAccountRegistRequest(msg)
	end
end

skynet.start(function()
	print("---start login server---")
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)
	
	protobuf = require "protobuf"
	local login_data = io.open("../message/login_message.pb", "rb")
	local buffer = login_data:read "*a"
	login_data:close()
	protobuf.register(buffer)

	skynet.register "loginserver"
end)
