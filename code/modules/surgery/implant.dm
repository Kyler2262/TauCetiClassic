//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.

//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity
	priority = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(!hasorgans(target))
			return 0
		if(!ishuman(target))
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open >= 2 && !(affected.status & ORGAN_BLEEDING) && (target_zone != BP_CHEST || target.op_stage.ribcage == 2)

	proc/get_max_wclass(datum/organ/external/affected)
		switch (affected.body_zone)
			if (BP_HEAD)
				return 1
			if (BP_CHEST)
				return 3
			if (BP_GROIN)
				return 2
		return 0

	proc/get_cavity(datum/organ/external/affected)
		switch (affected.body_zone)
			if (BP_HEAD)
				return "cranial"
			if (BP_CHEST)
				return "thoracic"
			if (BP_GROIN)
				return "abdominal"
		return ""

/datum/surgery_step/cavity/make_space
	allowed_tools = list(
	/obj/item/weapon/surgicaldrill = 100,	\
	/obj/item/weapon/pen = 75
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/affected = target.get_organ(target_zone)
			return !affected.cavity && !affected.hidden

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].", \
		"You start making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]." )
		target.custom_pain("The pain in your chest is living hell!",1)
		affected.cavity = 1
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/chest/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] makes some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].", \
		"\blue You make some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]." )

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/chest/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, scraping tissue inside [target]'s [affected.name] with \the [tool]!", \
		"\red Your hand slips, scraping tissue inside [target]'s [affected.name] with \the [tool]!")
		affected.createwound(CUT, 20)

/datum/surgery_step/cavity/close_space
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/affected = target.get_organ(target_zone)
			return affected.cavity

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts mending [target]'s [get_cavity(affected)] cavity wall with \the [tool].", \
		"You start mending [target]'s [get_cavity(affected)] cavity wall with \the [tool]." )
		target.custom_pain("The pain in your chest is living hell!",1)
		affected.cavity = 0
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/chest/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] mends [target]'s [get_cavity(affected)] cavity walls with \the [tool].", \
		"\blue You mend [target]'s [get_cavity(affected)] cavity walls with \the [tool]." )

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/chest/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, scraping tissue inside [target]'s [affected.name] with \the [tool]!", \
		"\red Your hand slips, scraping tissue inside [target]'s [affected.name] with \the [tool]!")
		affected.createwound(CUT, 20)

/datum/surgery_step/cavity/place_item
	priority = 0
	allowed_tools = list(/obj/item = 100)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/affected = target.get_organ(target_zone)
			return !affected.hidden && affected.cavity && tool.w_class <= get_max_wclass(affected)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.", \
		"You start putting \the [tool] inside [target]'s [get_cavity(affected)] cavity." )
		target.custom_pain("The pain in your chest is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/chest/affected = target.get_organ(target_zone)

		user.visible_message("\blue [user] puts \the [tool] inside [target]'s [get_cavity(affected)] cavity.", \
		"\blue You put \the [tool] inside [target]'s [get_cavity(affected)] cavity." )
		if (tool.w_class > get_max_wclass(affected)/2 && prob(50))
			to_chat(user, "\red You tear some blood vessels trying to fit such a big object in this cavity.")
			var/datum/wound/internal_bleeding/I = new (15)
			affected.wounds += I
			affected.owner.custom_pain("You feel something rip in your [affected.name]!", 1)
		if(istype(tool, /obj/item/gland))	//Abductor surgery integration
			if(target_zone != BP_CHEST)
				return
			else
				var/obj/item/gland/gland = tool
				user.drop_item()
				gland.Inject(target)
				affected.cavity = 0
				return
		user.drop_item()
		affected.hidden = tool
		tool.loc = target
		affected.cavity = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/chest/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, scraping tissue inside [target]'s [affected.name] with \the [tool]!", \
		"\red Your hand slips, scraping tissue inside [target]'s [affected.name] with \the [tool]!")
		affected.createwound(CUT, 20)

//////////////////////////////////////////////////////////////////
//					IMPLANT/ITEM REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity/implant_removal
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/affected = target.get_organ(target_zone)
			return ((affected.open == 3 && affected.body_zone == BP_CHEST) || (affected.open == 2))

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts poking around inside the incision on [target]'s [affected.name] with \the [tool].", \
		"You start poking around inside the incision on [target]'s [affected.name] with \the [tool]" )
		target.custom_pain("The pain in your chest is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/chest/affected = target.get_organ(target_zone)

		var/find_prob = 0

		if (affected.implants.len)

			var/obj/item/obj = affected.implants[1]

			if(istype(obj,/obj/item/weapon/implant))
				var/obj/item/weapon/implant/imp = obj
				if (imp.islegal())
					find_prob +=60
				else
					find_prob +=40
			else
				find_prob +=50

			if (prob(find_prob))
				user.visible_message("\blue [user] takes something out of incision on [target]'s [affected.name] with \the [tool].", \
				"\blue You take [obj] out of incision on [target]'s [affected.name]s with \the [tool]." )
				affected.implants -= obj

				target.hud_updateflag |= 1 << IMPLOYAL_HUD

				//Handle possessive brain borers.
				if(istype(obj,/mob/living/simple_animal/borer))
					var/mob/living/simple_animal/borer/worm = obj
					if(worm.controlling)
						target.release_control()
					worm.detatch()

				if(obj)
					obj.loc = get_turf(target)

					if(istype(obj,/obj/item/weapon/implant))
						var/obj/item/weapon/implant/imp = obj
						imp.imp_in = null
						imp.implanted = 0
						if(istype(imp,/obj/item/weapon/implant/storage))
							var/obj/item/weapon/implant/storage/Simp = imp
							Simp.removed()
			else
				user.visible_message("\blue [user] removes \the [tool] from [target]'s [affected.name].", \
				"\blue There's something inside [target]'s [affected.name], but you just missed it this time." )
		else if (affected.hidden)
			user.visible_message("\blue [user] takes something out of incision on [target]'s [affected.name] with \the [tool].", \
			"\blue You take something out of incision on [target]'s [affected.name]s with \the [tool]." )
			affected.hidden.loc = get_turf(target)
			if(!affected.hidden.blood_DNA)
				affected.hidden.blood_DNA = list()
			affected.hidden.blood_DNA[target.dna.unique_enzymes] = target.dna.b_type
			affected.hidden.update_icon()
			affected.hidden = null

		else
			user.visible_message("\blue [user] could not find anything inside [target]'s [affected.name], and pulls \the [tool] out.", \
			"\blue You could not find anything inside [target]'s [affected.name]." )

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/chest/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, scraping tissue inside [target]'s [affected.name] with \the [tool]!", \
		"\red Your hand slips, scraping tissue inside [target]'s [affected.name] with \the [tool]!")
		affected.createwound(CUT, 20)
		if (affected.implants.len)
			var/fail_prob = 10
			fail_prob += 100 - tool_quality(tool)
			if (prob(fail_prob))
				var/obj/item/weapon/implant/imp = affected.implants[1]
				user.visible_message("\red Something beeps inside [target]'s [affected.name]!")
				playsound(imp.loc, 'sound/items/countdown.ogg', 75, 1, -3)
				spawn(25)
					imp.activate()

