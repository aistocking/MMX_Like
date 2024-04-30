extends CanvasLayer

var Player

@onready var ChargeBar = $WholeScreen/ChargeBar
@onready var ChargeLevel = $WholeScreen/ChargeLevels
@onready var HealthBar = $WholeScreen/HealthBar

@onready var ChargePellet1 = $WholeScreen/ChargePellet1
@onready var ChargePellet2 = $WholeScreen/ChargePellet2
@onready var ChargePellet3 = $WholeScreen/ChargePellet3
@onready var ChargePellet4 = $WholeScreen/ChargePellet4
@onready var ChargePellet5 = $WholeScreen/ChargePellet5
@onready var ChargePellet6 = $WholeScreen/ChargePellet6

var CurrentPellet

func _ready():
	Player = get_tree().get_first_node_in_group("Player")
	HealthBar.value = Player.Health
	CurrentPellet = ChargePellet1


func changePellet():
	match Player.ChargeLevel:
		0:
			CurrentPellet = ChargePellet1
		1:
			CurrentPellet = ChargePellet2
		2:
			CurrentPellet = ChargePellet3
		3:
			CurrentPellet = ChargePellet4
		4:
			CurrentPellet = ChargePellet5
		5:
			CurrentPellet = ChargePellet6
		6:
			pass

func decreasePellet():
	CurrentPellet.value = 0
	changePellet()
