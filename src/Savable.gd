class_name Savable

## Base properties we don't want to save
const BASE_REFC_PROPS = [&"RefCounted", &"script", &"Built-in script", &"Savable.gd"]


func properties():
	return get_property_list() \
		.filter(func(prop): return not prop["name"] in BASE_REFC_PROPS) \
		.map(func(prop): return prop["name"])


func save_to_config(config: ConfigFile, section_name: String):
	for prop in properties() :
		config.set_value(section_name, prop, self.get(prop))

## Try to load ever properties from the config
static func load_from_config_or_default(config: ConfigFile, section_name: String, default: Savable) -> Savable:
	for prop in default.properties():
		if config.has_section_key(section_name, prop):
			default.set(prop, config.get_value(section_name, prop))
	return default

## Prints all the properties values
func _to_string():
	var res = ""
	for prop in properties() :
		res += prop + ": " + str(self.get(prop)) + ", "
	return res
