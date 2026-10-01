# Dawn: Smart Alarm

PROJECT     := Dawn.xcodeproj
SCHEME      := Dawn
CONFIG      := Debug
DERIVED     := build/DerivedData
TEAM_CONFIG := Config/Team.xcconfig
PACKAGES    := $(wildcard Packages/*)

.PHONY: all config build build-watch test install clean

all: build

config: $(TEAM_CONFIG)

$(TEAM_CONFIG): Config/Team.xcconfig.template
	cp $< $@
	@echo "Created $@. Fill in DEVELOPMENT_TEAM before 'make install'."

build: config
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIG) \
		-destination 'generic/platform=iOS' -derivedDataPath $(DERIVED) \
		CODE_SIGNING_ALLOWED=NO build

build-watch: config
	xcodebuild -project $(PROJECT) -scheme DawnWatch -configuration $(CONFIG) \
		-destination 'generic/platform=watchOS' -derivedDataPath $(DERIVED) \
		CODE_SIGNING_ALLOWED=NO build

test:
	@test -n "$(PACKAGES)" || { echo "No packages found under Packages/"; exit 1; }
	@for p in $(PACKAGES); do echo "== $$p"; swift test --package-path $$p || exit 1; done

install: config
	./Scripts/install.sh $(PROJECT) $(SCHEME) $(CONFIG) $(DERIVED)

clean:
	rm -rf build
	@for p in $(PACKAGES); do rm -rf $$p/.build; done
