extends slime

func _ready():
	speed = .5
	health = 5
	sleep()
	player = Events.player
	max_health = health
	catalog = Events.catalog
	Events.room_entered.connect(func(room):
		if room == get_parent():
			wake_up()
			spawning = false
		else:
			sleep()
	)

func _on_death_timer_timeout():
	catalog.unlock_enemy(EnemyTypes.enemy.green_slime)
	enemy_slain()
