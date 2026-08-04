// ROLE BALANCE SYSTEM

// if pop diff dips below this % threshold, balance lock will take place
#define DIFF_THRESHOLD 70
// will always lock faction if is HIGHER than this (regardless of total pop)
#define POP_DIFF_MAX 6
// will never lock if diff is LOWER than this (regardless of total pop)
#define POP_DIFF_MIN 3

/datum/controller/subsystem/job
	var/living_pop = list()
	var/locked_faction

/datum/controller/subsystem/job/proc/adjust_perse_count(datum/source, val)
	living_pop["Perserdun"] += val
	if(living_pop["Perserdun"] < 0)
		living_pop["Perserdun"] = 0
	balance_slots()

/datum/controller/subsystem/job/proc/adjust_risv_count(datum/source, val)
	living_pop["Risvon"] += val
	if(living_pop["Risvon"] < 0)
		living_pop["Risvon"] = 0
	balance_slots()


/datum/controller/subsystem/job/proc/is_faction_locked(department_flag)
	return department_flag == locked_faction

/datum/controller/subsystem/job/proc/lock_faction(department_flag)
	locked_faction = department_flag

/datum/controller/subsystem/job/proc/clear_faction_lock()
	JobDebug("Faction slots have been unlocked.")
	locked_faction = null

/datum/controller/subsystem/job/proc/balance_slots()
	var/perse = living_pop["Perserdun"]
	var/risv = living_pop["Risvon"]
	var/total = perse + risv
	var/diff = abs(perse - risv)
	var/goliath

	if(total == 0 || diff < POP_DIFF_MIN)
		clear_faction_lock()
		return

	if(perse > risv)
		goliath = PERSERDUN
	else if(perse < risv)
		goliath = RISVON

	var/balance_ratio = 1 - (diff / total)
	if(diff >= POP_DIFF_MAX || balance_ratio < (DIFF_THRESHOLD / 100))
		lock_faction(goliath)
		JobDebug("[goliath] slots have been balance-locked.")
		return
	
	clear_faction_lock()
