/obj/machinery/auto_cloner
	name = "mysterious pod"
	desc = "It's full of a viscous liquid, but appears dark and silent."
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "cellold0"
	var/spawn_type
	var/time_spent_spawning = 0
	var/time_per_spawn = 0
	var/last_process= 0
	density = TRUE
	var/previous_power_state = 0

	active_power_usage = 2000
	idle_power_usage = 1000

/obj/machinery/auto_cloner/New()
	..()

	time_per_spawn = rand(1200,3600)

	//33% chance to spawn nasties
	if(prob(33))
		spawn_type = pick(
		/mob/living/simple_animal/hostile/giant_spider/nurse,
		/mob/living/simple_animal/hostile/bear,
		/mob/living/simple_animal/hostile/creature)
	else
		spawn_type = pick(\
		/mob/living/simple_animal/friendly/cat,
		/mob/living/simple_animal/friendly/corgi,
		/mob/living/simple_animal/friendly/corgi/puppy,
		/mob/living/simple_animal/friendly/chicken,
		/mob/living/simple_animal/friendly/cow,
		/mob/living/simple_animal/hostile/retaliate/parrot,
		/mob/living/simple_animal/slime,
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/friendly/mouse,
		/mob/living/simple_animal/hostile/retaliate/goat,
		/mob/living/simple_animal/hostile/retaliate/goose)

//todo: how the hell is the asteroid permanently powered?
/obj/machinery/auto_cloner/Process()
	if(powered(power_channel))
		if(!previous_power_state)
			previous_power_state = 1
			icon_state = "cellold1"
			src.visible_message("<span class='notice'>[icon2html(src, viewers(get_turf(src)))] [src] suddenly comes to life!</span>")

		//slowly grow a mob
		if(prob(5))
			src.visible_message("<span class='notice'>[icon2html(src, viewers(get_turf(src)))] [src] [pick("gloops","glugs","whirrs","whooshes","hisses","purrs","hums","gushes")].</span>")

		//if we've finished growing...
		if(time_spent_spawning >= time_per_spawn)
			time_spent_spawning = 0
			update_use_power(POWER_USE_IDLE)
			src.visible_message("<span class='notice'>[icon2html(src, viewers(get_turf(src)))] [src] pings!</span>")
			icon_state = "cellold1"
			desc = "It's full of a bubbling viscous liquid, and is lit by a mysterious glow."
			if(spawn_type)
				new spawn_type(src.loc)

		//if we're getting close to finished, kick into overdrive power usage
		if(time_spent_spawning / time_per_spawn > 0.75)
			update_use_power(POWER_USE_ACTIVE)
			icon_state = "cellold2"
			desc = "It's full of a bubbling viscous liquid, and is lit by a mysterious glow. A dark shape appears to be forming inside..."
		else
			update_use_power(POWER_USE_IDLE)
			icon_state = "cellold1"
			desc = "It's full of a bubbling viscous liquid, and is lit by a mysterious glow."

		time_spent_spawning = time_spent_spawning + world.time - last_process
	else
		if(previous_power_state)
			previous_power_state = 0
			icon_state = "cellold0"
			src.visible_message("<span class='notice'>[icon2html(src, viewers(get_turf(src)))] [src] suddenly shuts down.</span>")

		//cloned mob slowly breaks down
		time_spent_spawning = max(time_spent_spawning + last_process - world.time, 0)

	last_process = world.time
