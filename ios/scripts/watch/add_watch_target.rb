#!/usr/bin/env ruby
# Adds the DoxaWatch watchOS app target to Runner.xcodeproj.
#
# The target is standalone: it is NOT a dependency of Runner and is NOT embedded
# in the iPhone app, so Runner builds, signs and ships exactly as before. Undo
# with remove_watch_target.rb. See docs/apple-watch.md.
#
# Usage (from ios/):  ruby scripts/watch/add_watch_target.rb
#
# Uses the xcodeproj gem, which CocoaPods already installs.

require "xcodeproj"

IOS_DIR = File.expand_path("../..", __dir__)
PROJECT_PATH = File.join(IOS_DIR, "Runner.xcodeproj")
TARGET_NAME = "DoxaWatch"
DEPLOYMENT_TARGET = "10.0"
TEAM_ID = "7WDLZXA935"

# Per flavor: the iPhone app this watch app belongs to, and its display name.
#
# The companion link (INFOPLIST_KEY_WKCompanionAppBundleIdentifier) is left out
# on purpose. If that key appears anywhere in project.pbxproj, `flutter build`
# switches every iPhone build into watch-companion mode (no -sdk/ARCHS, and
# simulator builds demand a device id). It goes in with the embedding step,
# when the watch app actually ships inside Runner. See docs/apple-watch.md.
FLAVORS = {
  "production" => { companion: "life.doxa.pray", display_name: "DOXA Prayer" },
  "staging" => { companion: "life.doxa.pray.staging", display_name: "DOXA Staging" },
}.freeze

project = Xcodeproj::Project.open(PROJECT_PATH)

if project.targets.any? { |t| t.name == TARGET_NAME }
  puts "#{TARGET_NAME} already exists in Runner.xcodeproj; nothing to do."
  exit 0
end

# --- Files -------------------------------------------------------------------

group = project.main_group.new_group(TARGET_NAME, TARGET_NAME)
sources = %w[DoxaWatchApp.swift ContentView.swift].map { |f| group.new_reference(f) }
assets = group.new_reference("Assets.xcassets")
xcconfig = group.new_reference("DoxaWatch.xcconfig")

# --- Target ------------------------------------------------------------------

target = project.new_target(:application, TARGET_NAME, :watchos, DEPLOYMENT_TARGET, nil, :swift)
target.add_file_references(sources)
target.add_resources([assets])

# new_target links Foundation.framework by a path into one specific watchOS SDK,
# which breaks on other Xcode versions. Swift imports it implicitly, so drop it.
target.frameworks_build_phase.files.to_a.each do |build_file|
  ref = build_file.file_ref
  build_file.remove_from_project
  ref.remove_from_project if ref && ref.build_files.empty?
end
project.frameworks_group.children
       .select { |g| g.display_name == "watchOS" && g.children.empty? }
       .each(&:remove_from_project)

# new_target only creates Debug/Release. Replace them with one configuration per
# project configuration (Debug-staging, Release-production, ...) so every scheme
# and `xcodebuild -configuration` value resolves for this target too.
config_list = project.new(Xcodeproj::Project::Object::XCConfigurationList)
config_list.default_configuration_is_visible = "0"
config_list.default_configuration_name = "Release-production"

project.build_configurations.map(&:name).each do |name|
  kind, flavor = name.split("-", 2)
  info = FLAVORS.fetch(flavor) { abort "Unknown flavor in configuration #{name}" }
  debug = kind == "Debug"

  config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
  config.name = name
  config.base_configuration_reference = xcconfig
  config.build_settings = {
    "ASSETCATALOG_COMPILER_APPICON_NAME" => "AppIcon-#{flavor}",
    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME" => "AccentColor",
    "CODE_SIGN_STYLE" => "Automatic",
    "DEVELOPMENT_TEAM" => TEAM_ID,
    "ENABLE_PREVIEWS" => "YES",
    "GENERATE_INFOPLIST_FILE" => "YES",
    "INFOPLIST_KEY_CFBundleDisplayName" => info[:display_name],
    "INFOPLIST_KEY_WKRunsIndependentlyOfCompanionApp" => "YES",
    "LD_RUNPATH_SEARCH_PATHS" => ["$(inherited)", "@executable_path/Frameworks"],
    "PRODUCT_BUNDLE_IDENTIFIER" => "#{info[:companion]}.watchkitapp",
    "PRODUCT_NAME" => "$(TARGET_NAME)",
    "SDKROOT" => "watchos",
    "SKIP_INSTALL" => "YES",
    "SUPPORTED_PLATFORMS" => "watchos watchsimulator",
    "SWIFT_EMIT_LOC_STRINGS" => "YES",
    "SWIFT_VERSION" => "5.0",
    "TARGETED_DEVICE_FAMILY" => "4",
    "WATCHOS_DEPLOYMENT_TARGET" => DEPLOYMENT_TARGET,
  }
  if debug
    config.build_settings["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = "DEBUG $(inherited)"
    config.build_settings["SWIFT_OPTIMIZATION_LEVEL"] = "-Onone"
  else
    config.build_settings["SWIFT_COMPILATION_MODE"] = "wholemodule"
    config.build_settings["SWIFT_OPTIMIZATION_LEVEL"] = "-O"
  end
  config_list.build_configurations << config
end

old_list = target.build_configuration_list
target.build_configuration_list = config_list
old_list.build_configurations.to_a.each(&:remove_from_project)
old_list.remove_from_project

project.save

# --- Schemes -----------------------------------------------------------------

FLAVORS.each_key do |flavor|
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(target)
  scheme.set_launch_target(target)
  scheme.launch_action.build_configuration = "Debug-#{flavor}"
  scheme.test_action.build_configuration = "Debug-#{flavor}"
  scheme.profile_action.build_configuration = "Profile-#{flavor}"
  scheme.analyze_action.build_configuration = "Debug-#{flavor}"
  scheme.archive_action.build_configuration = "Release-#{flavor}"
  scheme.save_as(PROJECT_PATH, "#{TARGET_NAME}-#{flavor}", true)
end

puts "Added #{TARGET_NAME} (watchOS #{DEPLOYMENT_TARGET}+) with schemes " \
     "#{FLAVORS.keys.map { |f| "#{TARGET_NAME}-#{f}" }.join(', ')}."
