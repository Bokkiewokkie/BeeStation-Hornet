/datum/computer_file/program/salary_manager
	filename = "salmngr"
	filedesc = "Budget Manager"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "id"
	extended_desc = "Program for managing department funds and employee salaries."
	transfer_access = list(ACCESS_HEADS)
	requires_ntnet = FALSE
	size = 4
	tgui_id = "NtosSalaryManager"
	program_icon = "clipboard-list"

	var/authenthicated = FALSE
	var/target_dept

/datum/computer_file/program/salary_manager/ui_static_data(mob/user)
	var/list/data = list()
	data["manifest"] = GLOB.data_core.get_manifest()
	return data

/datum/computer_file/program/salary_manager/ui_data(mob/user)
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	if(computer)
		data["have_printer"] = !!printer
	else
		data["have_printer"] = FALSE
	return data

/datum/computer_file/program/salary_manager/proc/authenticate(mob/user, obj/item/card/id/id_card)
	if(!id_card)
		return

	if(istype(id_card, /obj/item/card/id/departmental_budget) && !HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		var/obj/item/card/id/departmental_budget/ID = id_card
		switch(id_card.department_ID)


	region_access = list()
	if(!target_dept && (ACCESS_CHANGE_IDS in id_card.access))
		minor = FALSE
		authenticated = TRUE
		update_static_data(user)
		return TRUE

	var/list/head_types = list()
	for(var/access_text in sub_managers)
		var/list/info = sub_managers[access_text]
		var/access = text2num(access_text)
		if((access in id_card.access) && ((info["region"] in target_dept) || !length(target_dept)))
			region_access += info["region"]
			//I don't even know what I'm doing anymore
			head_types += info["head"]

	head_subordinates = list()
	if(length(head_types))
		for(var/j in SSjob.occupations)
			var/datum/job/job = j
			for(var/head in head_types)//god why
				if(head in job.department_head)
					head_subordinates += job.title

	if(length(region_access))
		minor = TRUE
		authenticated = TRUE
		update_static_data(user)
		return TRUE

	return FALSE

/datum/computer_file/program/salary_manager/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	switch(action)
		if("Salary_change")

