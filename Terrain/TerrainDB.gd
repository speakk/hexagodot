extends Node

enum TerrainType {
  Dirt, Water, Grass, Mountain
}

var terrains = {
  TerrainType.Dirt: {
    "scene": preload("res://Terrain/Dirt.tscn"),
  },
  TerrainType.Water: {
    "scene": preload("res://Terrain/Water.tscn"),
  },
  TerrainType.Grass: {
    "scene": preload("res://Terrain/Grass.tscn"),
  },
  TerrainType.Mountain: {
    "scene": preload("res://Terrain/Mountain.tscn"),
  },
}

func load_db_values(terrain, type):
  var data = terrains.get(type)
  #terrain.solid = data.solid

func create_terrain(type, q, r):
  var scene = terrains.get(type).get("scene")
  var terrain = scene.instance(type).init(q, r)

  load_db_values(terrain, type)
  return terrain
