extends Node

# requests
signal deselect_all

# notifications
signal terrain_targeted(position)
signal unit_targeted(unit)
signal unit_selected(unit)
signal unit_deselected(unit)
signal controlled_player_changed(player_id)
