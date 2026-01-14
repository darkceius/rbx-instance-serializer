-- round.luau
-- @darkceius

return function(num: number, _precision: number?)
	local precision = _precision or 10_000

	return math.floor(num * precision) / precision
end
