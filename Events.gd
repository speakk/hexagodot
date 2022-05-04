extends Node

signal spawner_finished(spawner)

signal unit_selected(unit)
signal unit_moved(unit, from, to)
signal unit_took_damage(unit, damage)
signal unit_attacked(by, against, damage)
