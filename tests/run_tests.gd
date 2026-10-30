## Minimal headless test runner.
## Usage: godot --headless -s res://tests/run_tests.gd [-- filter]
## Runs every test_* method in res://tests/unit/test_*.gd. Exits 1 on failure.
extends SceneTree

const TEST_DIR := "res://tests/unit"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var filter := ""
	var user_args := OS.get_cmdline_user_args()
	if user_args.size() > 0:
		filter = user_args[0]

	var passed := 0
	var failed := 0
	var files := Array(DirAccess.get_files_at(TEST_DIR))
	files.sort()
	for file: String in files:
		if not (file.begins_with("test_") and file.ends_with(".gd")):
			continue
		var script := load(TEST_DIR.path_join(file)) as GDScript
		if script == null or not script.can_instantiate():
			failed += 1
			print("  FAIL  ", file, " (could not load; see errors above)")
			continue
		var suite: TestSuite = script.new()
		suite.tree = self
		for method in script.get_script_method_list():
			var test_name: String = method["name"]
			if not test_name.begins_with("test_"):
				continue
			var full_name := "%s::%s" % [file.get_basename(), test_name]
			if filter and not full_name.contains(filter):
				continue
			suite.failures.clear()
			suite.before_each()
			await suite.call(test_name)
			suite.after_each()
			suite.free_owned_nodes()
			if suite.failures.is_empty():
				passed += 1
				print("  PASS  ", full_name)
			else:
				failed += 1
				print("  FAIL  ", full_name)
				for failure in suite.failures:
					print("        ", failure)

	print("\n%d passed, %d failed" % [passed, failed])
	if passed + failed == 0:
		push_error("No tests ran (filter: '%s')" % filter)
		quit(1)
		return
	quit(1 if failed > 0 else 0)
