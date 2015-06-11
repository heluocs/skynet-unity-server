local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local message = require "message"

pack = require("pack.core")

local CMD = {}
local protobuf = {}

local function processRoleLoginRequest(msg)
	print("---process login---")
	local role = protobuf.decode("CMsgRoleLoginRequest", msg)
	local nickname = role.nickname
	print("----nickname:" , nickname)

	local roles = {}

	local role = {}
	role.id = 1101
	role.nickname = "eternal"
	role.level = 1

	table.insert(roles, role)

	local tb = {}
	tb.role = roles

	local msgbody =  protobuf.encode("CMsgRoleLoginResponse", tb)
	return pack.pack(message.MSG_ROLE_LOGIN_RESPONSE_S2C, msgbody)
end

local function processRoleRegistRequest(msg)
	print("---process regist---")
	return nil
end

function CMD.dispatch(opcode, msg)
	print("login dispatch msgno " .. opcode)
	if opcode == message.MSG_ROLE_LOGIN_REQUEST_C2S & 0x0000FFFF then
		return processRoleLoginRequest(msg)
	elseif opcode == message.MSG_ROLE_REGIST_RESPONSE_C2S & 0x0000FFFF then
		return processRoleRegistRequest(msg)
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
