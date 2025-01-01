TARGET_DIR=~/Library/Preferences/Renoise/V3.4.3/Scripts/Tools/com.duftetools.SimplePianoroll.xrnx/

# Standard target to copy files
install:
	@echo "Copying main.lua and manifest.xml to $(TARGET_DIR)"
	cp ./main.lua $(TARGET_DIR)
	cp ./manifest.xml $(TARGET_DIR)

# Target to create .xrnx package
package:
	@echo "Creating .xrnx package"
	unlink out/com.duftetools.SimplePianoroll.xrnx || true
	zip out/com.duftetools.SimplePianoroll.xrnx manifest.xml main.lua

# Default target
.DEFAULT_GOAL := install

.PHONY: install package
