extends PanelContainer

@onready var _match = find_parent("Match")

@onready var _visible_player = find_child("VisiblePlayerSpinBox")


func _ready():
	await _match.ready
	if (
		_match.settings.visibility
		in [_match.settings.Visibility.FULL, _match.settings.Visibility.ALL_PLAYERS]
	):
		_visible_player.editable = false
	_visible_player.value = _match.players.find(_match.visible_player)
	_visible_player.value_changed.connect(_on_visible_player_spin_box_value_changed)


func _on_visible_player_spin_box_value_changed(value):
	_match.visible_player = (
		_match.players[value] if value >= 0 and value < _match.players.size() else null
	)
