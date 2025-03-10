/obj/structure/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A huge, pulsating yellow mass."
	max_integrity = BLOB_CORE_MAX_HP
	max_hit_damage = 40
	armor_type = /datum/armor/blob_core
	explosion_block = 6
	point_return = -1
	health_regen = 0 //we regen in Life() instead of when pulsed
	resistance_flags = LAVA_PROOF

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/blob/core)


/datum/armor/blob_core
	fire = 75
	acid = 90

/obj/structure/blob/core/Initialize(mapload, client/new_overmind = null, placed = 0)
	GLOB.blob_cores += src
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/point_of_interest)
	update_icon() //so it atleast appears
	if(!placed && !overmind)
		return INITIALIZE_HINT_QDEL
	if(overmind)
		update_icon()
	. = ..()

/obj/structure/blob/core/scannerreport()
	return "Directs the blob's expansion, gradually expands, and sustains nearby blob spores and blobbernauts."

/obj/structure/blob/core/update_icon()
	cut_overlays()
	color = null
	var/mutable_appearance/blob_overlay = mutable_appearance('icons/mob/blob.dmi', "blob")
	if(overmind)
		blob_overlay.color = overmind.blobstrain.color
	add_overlay(blob_overlay)
	add_overlay(mutable_appearance('icons/mob/blob.dmi', "blob_core_overlay"))

/obj/structure/blob/core/Destroy()
	GLOB.blob_cores -= src
	if(overmind)
		overmind.blob_core = null
	overmind = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/core/ex_act(severity, target)
	var/damage = 50 - 10 * severity //remember, the core takes half brute damage, so this is 20/15/10 damage based on severity
	take_damage(damage, BRUTE, BOMB, 0)

/obj/structure/blob/core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(atom_integrity > 0)
		if(overmind) //we should have an overmind, but...
			overmind.update_health_hud()

/obj/structure/blob/core/process(delta_time)
	if(QDELETED(src))
		return
	if(!overmind)
		qdel(src)
	if(overmind)
		overmind.blobstrain.core_process()
		overmind.update_health_hud()
	Pulse_Area(overmind, BLOB_CORE_CLAIM_RANGE, BLOB_CORE_PULSE_RANGE, BLOB_CORE_EXPAND_RANGE)

	for(var/obj/structure/blob/normal/B in range(BLOB_CORE_STRONG_REINFORCE_RANGE, src))
		if(DT_PROB(BLOB_REINFORCE_CHANCE, delta_time))
			B.change_to(/obj/structure/blob/shield/core, overmind)
	for(var/obj/structure/blob/normal/B in range(BLOB_CORE_REFLECTOR_REINFORCE_RANGE, src))
		if(DT_PROB(BLOB_REINFORCE_CHANCE, delta_time))
			B.change_to(/obj/structure/blob/shield/reflective, overmind)
	..()

/obj/structure/blob/core/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/stationloving, FALSE, TRUE)

/obj/structure/blob/core/onTransitZ(old_z, new_z)
	if(overmind && is_station_level(new_z))
		overmind.forceMove(get_turf(src))
	return ..()
