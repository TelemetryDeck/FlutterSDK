.PHONY: help get test analyze checklint lint example-get example-test clean test-all test-android test-ios test-macos test-native

help:
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


analyze: ## Run static analysis
	@flutter analyze

checklint: ## Checks the project for linting errors, used by the CI
	@dart format lib test --set-exit-if-changed

clean: ## Clean build artifacts
	@flutter clean

example-get: ## Install example app dependencies
	@cd example && flutter pub get

get: ## Install dependencies
	@flutter pub get

lint: ## Applies all auto-correctable lint issues and reformats all source files
	@dart format lib test

test: ## Run unit tests
	@flutter test

test-all: ## Run all tests (Dart + native bridges)
	@$(MAKE) test
	@$(MAKE) test-native

test-android: ## Run Android native bridge tests
	@cd example/android && ./gradlew telemetrydecksdk:testDebugUnitTest

test-ios: ## Run iOS native bridge tests
	@xcodebuild test -workspace example/ios/Runner.xcworkspace -scheme Runner -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=26.1,name=iPhone 17' -quiet

test-macos: ## Run macOS native bridge tests
	@xcodebuild test -workspace example/macos/Runner.xcworkspace -scheme Runner -destination 'platform=macOS' -quiet

test-native: ## Run all native bridge tests (iOS, macOS, Android)
	@$(MAKE) test-ios
	@$(MAKE) test-macos
	@$(MAKE) test-android
