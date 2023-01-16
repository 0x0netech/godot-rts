enum NavigationLayers {
	AIR = 1 << 0,
	TERRAIN = 1 << 1,
}

const OWNED_PLAYER_CIRCLE_COLOR = Color.GREEN
const ADVERSARY_PLAYER_CIRCLE_COLOR = Color.RED
const RESOURCE_CIRCLE_COLOR = Color.YELLOW
const DEFAULT_CIRCLE_COLOR = Color.WHITE


class Resources:
	class A:
		const COLOR = Color.BLUE

	class B:
		const COLOR = Color.RED


class Units:
	const PRODUCTION_COSTS = {
		"res://source/match/units/Worker.tscn":
		{
			"resource_a": 5,
			"resource_b": 0,
		}
	}
	const PRODUCTION_TIMES = {
		"res://source/match/units/Worker.tscn": 5.0,
	}
