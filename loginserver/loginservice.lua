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

	local sql = "select * from tb_account where account = '" .. account .. "'"
	local ok, result = pcall(skynet.call, "dbservice", "lua", "query", sql)

	local tb = {}
	if ok then
		print(#result)
		if #result > 0 then
			for key,value in pairs(result) do
				tb.accountid = value["id"]
			end
		end
		--[[
		for k, v in pairs(value) do
			print(k, v)
		end
		]]--
	end

	local msgbody =  protobuf.encode("CMsgAccountLoginResponse", tb)
	return msgpack.pack(message.MSG_ACCOUNT_LOGIN_RESPONSE_S2C, msgbody)
end

local function processAccountRegistRequest(msg)
	print("---process regist---")
	local data = protobuf.decode("CMsgAccountRegistRequest", msg)
	local account = data.account
	print("---account:", account)

	local tb = {}
	local id = os.time()
	local sql = "insert into tb_account(id, account) values(".. id ..",'".. account .."')"
	print(sql)
	local ok, result = pcall(skynet.call, "dbservice", "lua", "query", sql)
	if ok then
		tb.accountid = id
		print("regist user success!")
	end

	local msgbody = protobuf.encode("CMsgAccountRegistResponse", tb)
	return msgpack.pack(message.MSG_ACCOUNT_REGIST_RESPONSE_S2C, msgbody)
end

local function processRoleListRequest(msg)
	print("---process role list---")
	local data = protobuf.decode("CMsgRoleListRequest", msg)
	local account = data.account
	print("---account:", account)

	local tb = {}
	local sql = "select * from tb_role where account = '" .. account .. "'"
	local ok, result = pcall(skynet.call, "dbservice", "lua", "query", sql)
	if ok then
		for key,value in pairs(result) do
			tb.nickname = value["nickname"]
			tb.level = value["level"]
			tb.roletype = value["roletype"]
		end
	else
		print("---query error---")
	end

	local msgbody = protobuf.encode("CMsgRoleListResponse", tb)
	return msgpack.pack(message.MSG_ROLE_LIST_RESPONSE_S2C, msgbody)
end

local function processRoleCreateRequest(msg)

end

function CMD.dispatch(opcode, msg)
	print("login dispatch msgno " .. opcode)
	if opcode == message.MSG_ACCOUNT_LOGIN_REQUEST_C2S & 0x0000FFFF then
		return processAccountLoginRequest(msg)
	elseif opcode == message.MSG_ACCOUNT_REGIST_REQUEST_C2S & 0x0000FFFF then
		return processAccountRegistRequest(msg)
	elseif opcode == message.MSG_ROLE_LIST_REQUEST_C2S & 0x0000FFFF then
		return processRoleListResponse(msg)	
	elseif opcode == message.MSG_ROLE_CREATE_REQUEST_C2S & 0x0000FFFF then
		return processRoleCreateResponse(msg)
	end
end

skynet.start(function()
	print("---start login server---")
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)
	
	protobuf = require "protobuf"
	local login_data = io.open("../proto/login_message.pb", "rb")
	local buffer = login_data:read "*a"
	login_data:close()
	protobuf.register(buffer)

	skynet.register "loginservice"
end)
