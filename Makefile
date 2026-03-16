TARGET_DIR=~/Library/Preferences/Renoise/V3.5.4/Scripts/Tools/com.duftetools.SimplePianoroll.xrnx/

# Standard target to copy files
install:
	@echo "\033[1m==> Copying main.lua and manifest.xml to $(TARGET_DIR)\033[0m"
	cp ./main.lua $(TARGET_DIR)
	cp ./manifest.xml $(TARGET_DIR)

# Target to create .xrnx package
package:
	@echo "\033[1m==> Creating .xrnx package\033[0m"
	@version="$$(sed -n 's|.*<Version>\(.*\)</Version>.*|\1|p' manifest.xml)"; \
	api_version="$$(sed -n 's|.*<ApiVersion>\(.*\)</ApiVersion>.*|\1|p' manifest.xml)"; \
	package_name="com.duftetools.SimplePianoroll_v$${version}_api$${api_version}.xrnx"; \
	backup_file="$$(mktemp manifest.xml.XXXXXX)"; \
	cp manifest.xml "$$backup_file"; \
	trap 'mv "$$backup_file" manifest.xml' EXIT; \
	sed 's|<BuildInfo>Dev</BuildInfo>|<BuildInfo>Stable</BuildInfo>|' "$$backup_file" > manifest.xml; \
	rm -f "$$package_name"; \
	zip "$$package_name" manifest.xml main.lua thumbnail.png cover.png LICENSE

# Watch target to monitor changes in main.lua
watch:
	@make install
	@echo "\033[1m==> Watching for changes in main.lua...\033[0m"
	fswatch -o ./main.lua | xargs -n1 -I{} make install

# Default target
.DEFAULT_GOAL := install

.PHONY: install package watch
