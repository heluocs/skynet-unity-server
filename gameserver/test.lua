local message = require "message"
print(message.MSG_ROLE_LOGIN_REQUEST_C2S)

local module = message.MSG_ROLE_LOGIN_REQUEST_C2S >> 16
print(module)
