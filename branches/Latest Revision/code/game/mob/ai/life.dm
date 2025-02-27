/mob/ai/Life()
	//Being dead doesn't mean your temperature never changes
	var/turf/T = get_turf(src)

	var/obj/move/shuttlefloor = locate(/obj/move, T)	// fuck obj/move
	if (isturf(T))	//let cryo/sleeper handle adjusting body temp in their respective alter_health procs
		src.bodytemperature = adjustBodyTemp(src.bodytemperature, (shuttlefloor ? shuttlefloor.temp : T.temp), 1.0)

	if (src.stat == 2)
		return
	else
		if (src.healths)
			if (src.health >= 100)
				src.healths.icon_state = "aiHealth0"
			else
				if (src.health >= 75)
					src.healths.icon_state = "aiHealth1"
				else
					if (src.health >= 50)
						src.healths.icon_state = "aiHealth2"
					else
						if (src.health > 20)
							src.healths.icon_state = "aiHealth3"
						else
							src.healths.icon_state = "aiHealth4"
		if (src.stat!=0)
			src:cameraFollow = null
			src:current = null
			src:machine = null

		src.updatehealth()

		if (istype(T, /turf))
			var/ficheck = src.firecheck(T)
			if (ficheck)
				src.fireloss += ficheck * 10
				src.updatehealth()
				if (src.fire)
					src.fire.icon_state = "fire1"
			else if (src.fire)
				src.fire.icon_state = "fire0"


		if (src.health <= -100.0)
			death()
			return
		else if (src.health < 0)
			src.oxyloss++

		if (src.mach)
			if (src.machine)
				src.mach.icon_state = "mach1"
			else
				src.mach.icon_state = null

		if (src.machine)
			if (!( src.machine.check_eye(src) ))
				src.reset_view(null)

		//var/stage = 0
		if (src.client)
			//stage = 1
			if (istype(src, /mob/ai))
				var/blind = 0
				//stage = 2
				var/area/loc = null
				if (istype(T, /turf))
					//stage = 3
					loc = T.loc
					if (istype(loc, /area))
						//stage = 4
						if (!loc.power_equip)
							//stage = 5
							blind = 1

				if (!blind)
					//stage = 4.5
					if (src.blind.layer!=BACKGROUND_LAYER)
						src.blind.layer = BACKGROUND_LAYER
					src.sight |= SEE_TURFS
					src.sight |= SEE_MOBS
					src.sight |= SEE_INFRA
					src.sight |= SEE_OBJS
					src.see_in_dark = 8
					src.see_invisible = 2
					src.see_infrared = 8

					if (src:aiRestorePowerRoutine==2)
						src << "Alert cancelled. Power has been restored without our assistance."
						src:aiRestorePowerRoutine = 0
						spawn(1)
							while (src.oxyloss>0 && stat!=2)
								sleep(50)
								src.oxyloss-=1
							src.oxyloss = 0
						return
					else if (src:aiRestorePowerRoutine==3)
						src << "Alert cancelled. Power has been restored."
						src:aiRestorePowerRoutine = 0
						spawn(1)
							while (src.oxyloss>0 && stat!=2)
								sleep(50)
								src.oxyloss-=1
							src.oxyloss = 0
						return
				else

					//stage = 6
					src.blind.screen_loc = "1,1 to 15,15"
					if (src.blind.layer!=18)
						src.blind.layer = 18
					src.sight = src.sight&~SEE_TURFS
					src.sight = src.sight&~SEE_MOBS
					src.sight = src.sight&~SEE_INFRA
					src.sight = src.sight&~SEE_OBJS
					src.see_in_dark = 0
					src.see_invisible = 0
					src.see_infrared = 8

					if ((!loc.power_equip) || istype(T, /turf/space))
						if (src:aiRestorePowerRoutine==0)
							src:aiRestorePowerRoutine = 1
							src << "You've lost power!"
							if(ticker.killer != src)
								src.addLaw(0, "")
							for (var/index=4, index<11, index++)
								src.addLaw(index, "")
							spawn(50)
								while ((src:aiRestorePowerRoutine!=0) && stat!=2)
									src.oxyloss += 2
									sleep(50)

							spawn(20)
								src << "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection."
								sleep(50)
								if (loc.power_equip)
									if (!istype(T, /turf/space))
										src << "Alert cancelled. Power has been restored without our assistance."
										src:aiRestorePowerRoutine = 0
										return
								src << "Fault confirmed: missing external power. Shutting down main control system to save power."
								sleep(20)
								src << "Emergency control system online. Verifying connection to power network."
								sleep(50)
								if (istype(T, /turf/space))
									src << "Unable to verify! No power connection detected!"
									src:aiRestorePowerRoutine = 2
									return
								src << "Connection verified. Searching for APC in power network."
								sleep(50)
								var/obj/machinery/power/apc/theAPC = null
								for (var/something in loc)
									if (istype(something, /obj/machinery/power/apc))
										if (!(something:stat & BROKEN))
											theAPC = something
											break
								if (theAPC==null)
									src << "Unable to locate APC!"
									src:aiRestorePowerRoutine = 2
									return
								if (loc.power_equip)
									if (!istype(T, /turf/space))
										src << "Alert cancelled. Power has been restored without our assistance."
										src:aiRestorePowerRoutine = 0
										return
								src << "APC located. Optimizing route to APC to avoid needless power waste."
								sleep(50)
								theAPC = null
								for (var/something in loc)
									if (istype(something, /obj/machinery/power/apc))
										if (!(something:stat & BROKEN))
											theAPC = something
											break
								if (theAPC==null)
									src << "APC connection lost!"
									src:aiRestorePowerRoutine = 2
									return
								if (loc.power_equip)
									if (!istype(T, /turf/space))
										src << "Alert cancelled. Power has been restored without our assistance."
										src:aiRestorePowerRoutine = 0
										return
								src << "Best route identified. Hacking offline APC power port."
								sleep(50)
								theAPC = null
								for (var/something in loc)
									if (istype(something, /obj/machinery/power/apc))
										if (!(something:stat & BROKEN))
											theAPC = something
											break
								if (theAPC==null)
									src << "APC connection lost!"
									src:aiRestorePowerRoutine = 2
									return
								if (loc.power_equip)
									if (!istype(T, /turf/space))
										src << "Alert cancelled. Power has been restored without our assistance."
										src:aiRestorePowerRoutine = 0
										return
								src << "Power port upload access confirmed. Loading control program into APC power port software."
								sleep(50)
								theAPC = null
								for (var/something in loc)
									if (istype(something, /obj/machinery/power/apc))
										if (!(something:stat & BROKEN))
											theAPC = something
											break
								if (theAPC==null)
									src << "APC connection lost!"
									src:aiRestorePowerRoutine = 2
									return
								if (loc.power_equip)
									if (!istype(T, /turf/space))
										src << "Alert cancelled. Power has been restored without our assistance."
										src:aiRestorePowerRoutine = 0
										return
								src << "Transfer complete. Forcing APC to execute program."
								sleep(50)
								src << "Receiving control information from APC."
								sleep(2)
								//bring up APC dialog
								theAPC.attack_ai(src)
								src:aiRestorePowerRoutine = 3
								src << "Your laws have been reset:"
								src.showLaws(0)