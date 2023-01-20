all:
	tuist fetch
	tuist generate --no-open --no-cache

update:
	tuist fetch --update
	tuist generate --no-open --no-cache

build_debug:
	tuist build --generate --configuration Debug --build-output-path .build/
	cp -r .build/Debug/CompanionAI.app CompanionAI_debug.app

build_release:
	tuist build --generate --configuration Release --build-output-path .build/
	cp -r .build/Release/CompanionAI.app CompanionAI.app

run:
	tuist build --generate --configuration Debug --build-output-path .build/
	.build/Debug/CompanionAI.app/Contents/MacOS/CompanionAI
