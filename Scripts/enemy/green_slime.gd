extends slime

# inherits everything from the slime

# sets the enemy's stats
# these are different from the blue slimes
func _ready():
	speed = .6
	health = 8
	sleep()
	player = Events.player
	max_health = health
	catalog = Events.catalog

# when the green slime dies, unlock the green slime in the catalog and call enemy slain
func _on_death_timer_timeout():
	catalog.unlock_enemy(EnemyTypes.enemy.green_slime)
	enemy_slain()
