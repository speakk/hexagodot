extends Node

signal spawner_finished(spawner)

signal unit_selected(unit)
signal deselected()
signal unit_moved(unit, from, to)
signal unit_entered_hex(unit, hex)
signal unit_took_damage(unit, damage)
signal unit_attacked(by, against, damage)
signal unit_died(unit)
signal hero_died(unit)
signal item_spawned(item, coordinate)


signal on_inventory_item_added(inventory, item)
