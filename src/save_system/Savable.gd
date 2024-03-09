class_name Savable

## Base properties we don't want to save
const BASE_REFC_PROPS = [&"RefCounted", &"script", &"Built-in script", &"Savable.gd"]


func properties():
	return get_property_list() \
		.filter(func(prop): return not prop["name"] in BASE_REFC_PROPS) \
		.map(func(prop): return prop["name"])


func save_to_config(config: ConfigFile, section_name: String):
	for prop_name in properties():
		var prop = self.get(prop_name)
		if prop is Savable:
			prop = prop.to_bytes_dict()
		#if prop is Savable:
			#prop.save_to_config(config, section_name + "_" + prop_name)
		config.set_value(section_name, prop_name, prop)

func to_bytes_dict():
	var result = {}
	for prop_name in properties():
		result[prop_name] = var_to_bytes(self.get(prop_name))
	return result


static func from_bytes_dict_or_default(dict: Dictionary, default: Savable):
	for prop_name in dict.keys():
		default.set(prop_name, bytes_to_var(dict[prop_name]))
	return default
	

## Try to load ever properties from the config
static func load_from_config_or_default(config: ConfigFile, section_name: String, default: Savable) -> Savable:
	for prop_name in default.properties():
		if config.has_section_key(section_name, prop_name):
			var value = config.get_value(section_name, prop_name)
			if default.get(prop_name) is Savable:
				value = Savable.from_bytes_dict_or_default(value, default.get(prop_name))
			default.set(prop_name, value)
	return default

## Prints all the properties values
func _to_string():
	var res = ""
	for prop in properties() :
		res += prop + ": " + str(self.get(prop)) + ", "
	return res
