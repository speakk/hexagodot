extends HBoxContainer

func init(item: Item):
  $Label.text = item.item_name
  $TextureRect.texture = item.get_texture()
  print("Set texture!", item.get_texture())
  return self
