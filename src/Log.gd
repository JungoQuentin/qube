extends Node

############
#### Autoload simpa qui permet de formater no print plus efficacement
#### Et d'avoir un niveau de log !
############

enum {
	DEBUG,
	INFO,
	ERROR,
}

#var level = INFO
var level = INFO

func _time(ms:bool = false):
	var time_return: String = Time.get_date_string_from_system()
	var milliseconds: int = Time.get_ticks_msec()
	var microseconds: int = Time.get_ticks_usec() - milliseconds * 1000
	if ms:
		time_return += " - " + (milliseconds as String)
		time_return += "." + (microseconds as String) + "us"
	return time_return

func debug(a="",b="",c="",d="",e="",f="",g="",h=""):
	if not level > DEBUG:
		print(_time(true), " | ", a, b, c, d, e, f, g, h)

func info(a="",b="",c="",d="",e="",f="",g="",h=""):
	if not level > INFO:
		print(_time(), " | ", a, b, c, d, e, f, g, h)

func error(a="",b="",c="",d="",e="",f="",g="",h=""):
	printerr(_time(), " | ", a, b, c, d, e, f, g, h)	
	print_stack()

func crash(a="",b="",c="",d="",e="",f="",g="",h=""):
	printerr(_time(), " | ", a, b, c, d, e, f, g, h)	
	print_stack()
	get_tree().quit()
