## Renders the main scene in a real window for a few frames and saves a PNG.
## Usage: godot -s res://tools/capture.gd -- [--out=path.png] [--frames=N] [--scene=res://...]
## Needs a display: does not work with --headless.
extends SceneTree

const DEFAULT_SCENE := "res://scenes/main.tscn"
const DEFAULT_OUT := "build/screenshots/capture.png"
const DEFAULT_FRAMES := 5


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var options := _parse_args()
	var scene_path: String = options.get("scene", DEFAULT_SCENE)
	var main: Node = (load(scene_path) as PackedScene).instantiate()
	root.add_child(main)
	for i in int(options.get("frames", str(DEFAULT_FRAMES))):
		await process_frame

	var out := ProjectSettings.globalize_path("res://").path_join(options.get("out", DEFAULT_OUT))
	DirAccess.make_dir_recursive_absolute(out.get_base_dir())
	var error := root.get_texture().get_image().save_png(out)
	print("Saved %s" % out if error == OK else "Save failed: %d" % error)
	quit(0 if error == OK else 1)


func _parse_args() -> Dictionary:
	var options := {}
	for arg in OS.get_cmdline_user_args():
		var parts := arg.trim_prefix("--").split("=", true, 1)
		options[parts[0]] = parts[1] if parts.size() > 1 else ""
	return options
