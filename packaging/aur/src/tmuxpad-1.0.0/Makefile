ID      = org.tsy.tmuxpad
DOMAIN  = plasma_applet_$(ID)
VERSION = $(shell sed -n 's/.*"Version": "\([^"]*\)".*/\1/p' metadata.json)
LOCALE_DIR ?= $(HOME)/.local/share/locale

QML_SOURCES = contents/ui/*.qml contents/config/config.qml

.PHONY: install uninstall upgrade pot translations install-translations bundle-translations package clean

## Install the plasmoid for the current user (also installs translations)
install: bundle-translations
	kpackagetool6 -t Plasma/Applet -i . 2>/dev/null || kpackagetool6 -t Plasma/Applet -u .

uninstall:
	kpackagetool6 -t Plasma/Applet -r $(ID)

upgrade:
	kpackagetool6 -t Plasma/Applet -u .

## Extract translatable strings into po/$(DOMAIN).pot
pot:
	xgettext --from-code=UTF-8 -L JavaScript \
		-ki18nd:2 -ki18ndc:2c,3 -ki18ndp:2,3 -ki18ndcp:2c,3,4 \
		--package-name=tmuxpad --package-version=$(VERSION) \
		-o po/$(DOMAIN).pot $(QML_SOURCES)

## Compile po/*.po into build/locale/
translations:
	@for po in po/*.po; do \
		lang=$$(basename $$po .po); \
		mkdir -p build/locale/$$lang/LC_MESSAGES; \
		msgfmt -o build/locale/$$lang/LC_MESSAGES/$(DOMAIN).mo $$po; \
		echo "built $$lang"; \
	done

## Install compiled translations into $(LOCALE_DIR)
install-translations: translations
	@for po in po/*.po; do \
		lang=$$(basename $$po .po); \
		mkdir -p $(LOCALE_DIR)/$$lang/LC_MESSAGES; \
		install -m 644 build/locale/$$lang/LC_MESSAGES/$(DOMAIN).mo \
			$(LOCALE_DIR)/$$lang/LC_MESSAGES/$(DOMAIN).mo; \
		echo "installed $$lang -> $(LOCALE_DIR)"; \
	done

## Bundle compiled translations INSIDE the package (contents/locale/), so a
## .plasmoid installed via the KDE Store ships with its translations.
bundle-translations:
	@for po in po/*.po; do \
		lang=$$(basename $$po .po); \
		mkdir -p contents/locale/$$lang/LC_MESSAGES; \
		msgfmt -o contents/locale/$$lang/LC_MESSAGES/$(DOMAIN).mo $$po; \
		echo "bundled $$lang -> contents/locale/"; \
	done

## Build a .plasmoid package for the KDE Store (with bundled translations)
package: bundle-translations
	rm -f tmuxpad-$(VERSION).plasmoid
	zip -r tmuxpad-$(VERSION).plasmoid metadata.json contents -x '*.qmlc'

clean:
	rm -rf build *.plasmoid contents/locale
