local exports = {}
exports.prefix = "Serializer |"

function exports.print(...)
	return print(exports.prefix, ...)
end

function exports.warn(...)
	return warn(exports.prefix, ...)
end

return exports
