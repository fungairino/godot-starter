GODOT     := tools/godot.sh
GDTOOLKIT := uvx --from gdtoolkit==4.5.0
GD_DIRS   := scripts tests tools
BUILD_DIR := build
APP_NAME  := game

.DEFAULT_GOAL := help
.PHONY: help install-godot install-templates api-docs import run editor test smoke screenshot lint format format-check check \
	export-web export-linux export-windows export-macos export-all clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

install-godot: ## Download the pinned Godot version into .godot-bin/
	tools/install-godot.sh

install-templates: ## Download Godot + export templates (needed for export-*)
	tools/install-godot.sh --templates

api-docs: ## Dump the engine API reference (XML) for the pinned version into .godot-bin/api-docs/
	@mkdir -p .godot-bin/api-docs
	cd .godot-bin/api-docs && "$$(../../$(GODOT) --print-path)" --headless --doctool .

import: ## Import assets and rebuild the class cache (run after adding class_name or assets)
	$(GODOT) --headless --import

run: ## Run the game
	$(GODOT)

editor: ## Open the project in the Godot editor
	$(GODOT) --editor

test: import ## Run unit tests headless (FILTER=substring to narrow)
	$(GODOT) --headless -s res://tests/run_tests.gd -- $(FILTER)

smoke: import ## Boot the main scene headless and fail on errors
	tools/smoke.sh

screenshot: import ## Save a PNG of the main scene (ARGS="--frames=10 --out=build/screenshots/x.png")
	$(GODOT) -s res://tools/capture.gd -- --out=build/screenshots/capture.png $(ARGS)

lint: ## Lint GDScript with gdlint
	$(GDTOOLKIT) gdlint $(GD_DIRS)

format: ## Format GDScript with gdformat
	$(GDTOOLKIT) gdformat $(GD_DIRS)

format-check: ## Check GDScript formatting without writing
	$(GDTOOLKIT) gdformat --check $(GD_DIRS)

check: lint format-check test smoke ## Everything CI runs

export-web: import ## Export the Web build to build/web/
	@mkdir -p $(BUILD_DIR)/web
	$(GODOT) --headless --export-release "Web" $(BUILD_DIR)/web/index.html

export-linux: import ## Export the Linux build to build/linux/
	@mkdir -p $(BUILD_DIR)/linux
	$(GODOT) --headless --export-release "Linux" $(BUILD_DIR)/linux/$(APP_NAME).x86_64

export-windows: import ## Export the Windows build to build/windows/
	@mkdir -p $(BUILD_DIR)/windows
	$(GODOT) --headless --export-release "Windows Desktop" $(BUILD_DIR)/windows/$(APP_NAME).exe

export-macos: import ## Export the macOS build to build/macos/
	@mkdir -p $(BUILD_DIR)/macos
	$(GODOT) --headless --export-release "macOS" $(BUILD_DIR)/macos/$(APP_NAME).zip

export-all: export-web export-linux export-windows export-macos ## Export every platform

clean: ## Remove build output and the import cache
	rm -rf $(BUILD_DIR) .godot
