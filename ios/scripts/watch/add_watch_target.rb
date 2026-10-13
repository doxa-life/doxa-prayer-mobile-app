#!/usr/bin/env ruby
# Adds the DOXA watch app to Runner.xcodeproj: the DoxaWatch watchOS app and
# its DoxaWatchWidgets extension (the complication / Smart Stack widget), which
# is embedded in the watch app.
#
# Both are standalone: neither is a dependency of Runner nor embedded in the
# iPhone app, so Runner builds, signs and ships exactly as before. Undo with
# remove_watch_target.rb. See docs/apple-watch.md.
#
# Usage (from ios/):  ruby scripts/watch/add_watch_target.rb
# After adding or removing files under DoxaWatch/ or DoxaWatchWidgets/, run
# remove_watch_target.rb and then this again; files are picked up by folder.
#
# Uses the xcodeproj gem, which CocoaPods already installs.

require "xcodeproj"

IOS_DIR = File.expand_path("../..", __dir__)
PROJECT_PATH = File.join(IOS_DIR, "Runner.xcodeproj")
APP_NAME = "DoxaWatch"
WIDGET_NAME = "DoxaWatchWidgets"
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

if project.targets.any? { |t| [APP_NAME, WIDGET_NAME].include?(t.name) }
  puts "#{APP_NAME} already exists in Runner.xcodeproj; nothing to do."
  exit 0
end

# --- Files -------------------------------------------------------------------
#
# Each folder is mirrored as groups. Swift files are compiled, asset and string
# catalogs bundled. Swift files under DoxaWatch/Shared/ and the string catalog
# go into both targets.

RESOURCE_EXTENSIONS = %w[.xcassets .json].freeze
REF_ONLY_EXTENSIONS = %w[.xcconfig .entitlements .plist].freeze

Files = Struct.new(:sources, :resources, :shared_sources, :shared_resources, :refs)

def collect(group, dir, files, shared: false)
  Dir.children(dir).sort.each do |name|
    next if name.start_with?(".")
    path = File.join(dir, name)
    ext = File.extname(name)
    if File.directory?(path) && ext != ".xcassets"
      collect(group.new_group(name, name), path, files, shared: shared || name == "Shared")
    elsif ext == ".swift"
      (shared ? files.shared_sources : files.sources) << group.new_reference(name)
    elsif ext == ".xcstrings"
      files.shared_resources << group.new_reference(name)
    elsif RESOURCE_EXTENSIONS.include?(ext)
      files.resources << group.new_reference(name)
    elsif REF_ONLY_EXTENSIONS.include?(ext)
      files.refs[name] = group.new_reference(name)
    end
  end
end

app_files = Files.new([], [], [], [], {})
app_group = project.main_group.new_group(APP_NAME, APP_NAME)
collect(app_group, File.join(IOS_DIR, APP_NAME), app_files)
xcconfig = app_files.refs.fetch("#{APP_NAME}.xcconfig") { abort "#{APP_NAME}.xcconfig not found" }

# The thank-you verses are the phone's own file, referenced rather than copied,
# so there is one source of truth for them.
app_files.resources << app_group.new_reference("../assets/thank_you_verses.json", :project)

widget_files = Files.new([], [], [], [], {})
widget_group = project.main_group.new_group(WIDGET_NAME, WIDGET_NAME)
collect(widget_group, File.join(IOS_DIR, WIDGET_NAME), widget_files)

# --- Targets -----------------------------------------------------------------

def new_watch_target(project, type, name)
  target = project.new_target(type, name, :watchos, DEPLOYMENT_TARGET, nil, :swift)
  # new_target links Foundation.framework by a path into one specific watchOS
  # SDK, which breaks on other Xcode versions. Swift imports it implicitly.
  target.frameworks_build_phase.files.to_a.each do |build_file|
    ref = build_file.file_ref
    build_file.remove_from_project
    ref.remove_from_project if ref && ref.build_files.empty?
  end
  project.frameworks_group.children
         .select { |g| g.display_name == "watchOS" && g.children.empty? }
         .each(&:remove_from_project)
  target
end

# new_target only creates Debug/Release. Replace them with one configuration
# per project configuration (Debug-staging, Release-production, ...) so every
# scheme and `xcodebuild -configuration` value resolves for these targets too.
def configure(project, target, xcconfig)
  list = project.new(Xcodeproj::Project::Object::XCConfigurationList)
  list.default_configuration_is_visible = "0"
  list.default_configuration_name = "Release-production"

  project.build_configurations.map(&:name).each do |name|
    kind, flavor = name.split("-", 2)
    info = FLAVORS.fetch(flavor) { abort "Unknown flavor in configuration #{name}" }
    debug = kind == "Debug"
    # STAGING points the app at the staging server, like the phone's flavor.
    conditions = [("DEBUG" if debug), ("STAGING" if flavor == "staging")].compact

    config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
    config.name = name
    config.base_configuration_reference = xcconfig
    config.build_settings = {
      "CODE_SIGN_STYLE" => "Automatic",
      "DEVELOPMENT_TEAM" => TEAM_ID,
      # Shared by the app and the widget; SharedStore derives the same id.
      "DOXA_APP_GROUP" => "group.#{info[:companion]}.watch",
      "ENABLE_PREVIEWS" => "YES",
      "GENERATE_INFOPLIST_FILE" => "YES",
      "INFOPLIST_KEY_CFBundleDisplayName" => info[:display_name],
      "PRODUCT_NAME" => "$(TARGET_NAME)",
      "SDKROOT" => "watchos",
      "SKIP_INSTALL" => "YES",
      "SUPPORTED_PLATFORMS" => "watchos watchsimulator",
      "SWIFT_ACTIVE_COMPILATION_CONDITIONS" => (conditions + ["$(inherited)"]).join(" "),
      "SWIFT_EMIT_LOC_STRINGS" => "YES",
      "SWIFT_VERSION" => "5.0",
      "TARGETED_DEVICE_FAMILY" => "4",
      "WATCHOS_DEPLOYMENT_TARGET" => DEPLOYMENT_TARGET,
    }
    if debug
      config.build_settings["SWIFT_OPTIMIZATION_LEVEL"] = "-Onone"
    else
      config.build_settings["SWIFT_COMPILATION_MODE"] = "wholemodule"
      config.build_settings["SWIFT_OPTIMIZATION_LEVEL"] = "-O"
    end
    yield config.build_settings, flavor, info
    list.build_configurations << config
  end

  old_list = target.build_configuration_list
  target.build_configuration_list = list
  old_list.build_configurations.to_a.each(&:remove_from_project)
  old_list.remove_from_project
end

app = new_watch_target(project, :application, APP_NAME)
app.add_file_references(app_files.sources + app_files.shared_sources)
app.add_resources(app_files.resources + app_files.shared_resources)
configure(project, app, xcconfig) do |settings, flavor, info|
  settings.merge!(
    "ASSETCATALOG_COMPILER_APPICON_NAME" => "AppIcon-#{flavor}",
    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME" => "AccentColor",
    "CODE_SIGN_ENTITLEMENTS" => "#{APP_NAME}/#{APP_NAME}.entitlements",
    # watchOS requires either a companion id or WKWatchOnly. Until embedding
    # (see the companion note above) the app declares itself watch-only; at
    # embedding this becomes WKCompanionAppBundleIdentifier plus
    # WKRunsIndependentlyOfCompanionApp (neither can be combined with it).
    "INFOPLIST_KEY_WKWatchOnly" => "YES",
    "LD_RUNPATH_SEARCH_PATHS" => ["$(inherited)", "@executable_path/Frameworks"],
    "PRODUCT_BUNDLE_IDENTIFIER" => "#{info[:companion]}.watchkitapp",
  )
end

widget = new_watch_target(project, :app_extension, WIDGET_NAME)
widget.add_file_references(widget_files.sources + app_files.shared_sources)
widget.add_resources(app_files.shared_resources)
configure(project, widget, xcconfig) do |settings, _flavor, info|
  settings.merge!(
    "APPLICATION_EXTENSION_API_ONLY" => "YES",
    "CODE_SIGN_ENTITLEMENTS" => "#{WIDGET_NAME}/#{WIDGET_NAME}.entitlements",
    "INFOPLIST_FILE" => "#{WIDGET_NAME}/Info.plist",
    "LD_RUNPATH_SEARCH_PATHS" => ["$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks"],
    "PRODUCT_BUNDLE_IDENTIFIER" => "#{info[:companion]}.watchkitapp.widgets",
  )
end

# Embed the widget in the watch app (not in Runner).
app.add_dependency(widget)
embed = app.new_copy_files_build_phase("Embed Foundation Extensions")
embed.symbol_dst_subfolder_spec = :plug_ins
embed.add_file_reference(widget.product_reference, true).settings = { "ATTRIBUTES" => ["RemoveHeadersOnCopy"] }

project.save

# --- Schemes -----------------------------------------------------------------

FLAVORS.each_key do |flavor|
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(app)
  scheme.set_launch_target(app)
  scheme.launch_action.build_configuration = "Debug-#{flavor}"
  scheme.test_action.build_configuration = "Debug-#{flavor}"
  scheme.profile_action.build_configuration = "Profile-#{flavor}"
  scheme.analyze_action.build_configuration = "Debug-#{flavor}"
  scheme.archive_action.build_configuration = "Release-#{flavor}"
  scheme.save_as(PROJECT_PATH, "#{APP_NAME}-#{flavor}", true)
end

puts "Added #{APP_NAME} and #{WIDGET_NAME} (watchOS #{DEPLOYMENT_TARGET}+) with schemes " \
     "#{FLAVORS.keys.map { |f| "#{APP_NAME}-#{f}" }.join(', ')}."
