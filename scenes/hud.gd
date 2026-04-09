extends CanvasLayer

@onready var score_label = $ScoreLabel
var score = 0

func _ready():
	add_to_group("HUD")

func add_score(amount):
	score += amount
	score_label.text = "Score: " + str(score)
