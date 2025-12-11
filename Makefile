TARGET_DIR=~/Library/Preferences/Renoise/V3.5.4/Scripts/Tools/com.duftetools.SimplePianoroll.xrnx/

# Standard target to copy files
install:
	@echo "\033[1m==> Copying main.lua and manifest.xml to $(TARGET_DIR)\033[0m"
	cp ./main.lua $(TARGET_DIR)
	cp ./manifest.xml $(TARGET_DIR)

# Target to create .xrnx package
package:
	@echo "\033[1m==> Creating .xrnx package\033[0m"
	unlink out/com.duftetools.SimplePianoroll.xrnx || true
	zip out/com.duftetools.SimplePianoroll.xrnx manifest.xml main.lua thumbnail.png cover.png

# Watch target to monitor changes in main.lua
watch:
	@make install
	@echo "\033[1m==> Watching for changes in main.lua...\033[0m"
	fswatch -o ./main.lua | xargs -n1 -I{} make install

# Default target
.DEFAULT_GOAL := install

.PHONY: install package watch
