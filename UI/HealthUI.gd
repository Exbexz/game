extends Control

onready var heartUIEmpty = $HeartUIEmpty
onready var heartUIFull = $HeartUIFull

var hearts = PlayerStats.health setget set_hearts
var max_hearts = PlayerStats.max_health setget get_max_hearts

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * 15
	
	
func get_max_hearts(value):
	max_hearts = max(value, 1)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * 15
	
func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")
