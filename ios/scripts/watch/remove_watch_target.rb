#!/usr/bin/env ruby
# Removes everything add_watch_target.rb put in Runner.xcodeproj: the DoxaWatch
# target, its file group, product reference and shared schemes. The source
# folder ios/DoxaWatch/ is left on disk; delete it yourself if the watch app is
# being dropped for good. See docs/apple-watch.md.
#
# Usage (from ios/):  ruby scripts/watch/remove_watch_target.rb

require "fileutils"
require "xcodeproj"

IOS_DIR = File.expand_path("../..", __dir__)
PROJECT_PATH = File.join(IOS_DIR, "Runner.xcodeproj")
TARGET_NAME = "DoxaWatch"

project = Xcodeproj::Project.open(PROJECT_PATH)

target = project.targets.find { |t| t.name == TARGET_NAME }
if target
  # Drop the target from any other target's dependencies or embed phases, in
  # case it was wired into Runner after the initial setup.
  project.targets.each do |other|
    other.dependencies.select { |d| d.target == target }.each(&:remove_from_project)
    other.copy_files_build_phases.each do |phase|
      phase.files.select { |f| f.file_ref == target.product_reference }.each(&:remove_from_project)
    end
  end
  # remove_from_project doesn't cascade to the target's build phases or
  # configurations, so take those out explicitly.
  target.build_phases.to_a.each do |phase|
    phase.files.to_a.each(&:remove_from_project)
    phase.remove_from_project
  end
  config_list = target.build_configuration_list
  config_list.build_configurations.to_a.each(&:remove_from_project)
  config_list.remove_from_project
  target.product_reference&.remove_from_project
  target.remove_from_project
end

def remove_group(group)
  group.children.to_a.each do |child|
    child.is_a?(Xcodeproj::Project::Object::PBXGroup) ? remove_group(child) : child.remove_from_project
  end
  group.remove_from_project
end

project.main_group.children
       .select { |c| c.display_name == TARGET_NAME && c.is_a?(Xcodeproj::Project::Object::PBXGroup) }
       .each { |g| remove_group(g) }

# An SDK-pinned Foundation.framework group, which early versions of
# add_watch_target.rb left behind.
project.frameworks_group.children
       .select { |g| g.display_name == "watchOS" && g.is_a?(Xcodeproj::Project::Object::PBXGroup) }
       .each { |g| remove_group(g) }

project.save

Dir.glob(File.join(PROJECT_PATH, "xcshareddata", "xcschemes", "#{TARGET_NAME}-*.xcscheme"))
   .each { |path| FileUtils.rm(path) }

puts target ? "Removed #{TARGET_NAME} from Runner.xcodeproj." : "#{TARGET_NAME} was not in Runner.xcodeproj."
