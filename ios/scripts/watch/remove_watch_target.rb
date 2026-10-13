#!/usr/bin/env ruby
# Removes everything add_watch_target.rb put in Runner.xcodeproj: the DoxaWatch
# and DoxaWatchWidgets targets, their file groups, products and shared schemes.
# The source folders (ios/DoxaWatch/, ios/DoxaWatchWidgets/) stay on disk;
# delete them yourself if the watch app is being dropped for good. See
# docs/apple-watch.md.
#
# Usage (from ios/):  ruby scripts/watch/remove_watch_target.rb

require "fileutils"
require "xcodeproj"

IOS_DIR = File.expand_path("../..", __dir__)
PROJECT_PATH = File.join(IOS_DIR, "Runner.xcodeproj")
NAMES = %w[DoxaWatch DoxaWatchWidgets].freeze

project = Xcodeproj::Project.open(PROJECT_PATH)

targets = project.targets.select { |t| NAMES.include?(t.name) }
targets.each do |target|
  # Drop the target from any other target's dependencies or embed phases,
  # including Runner's, in case it was wired in after the initial setup.
  project.targets.each do |other|
    other.dependencies.select { |d| d.target == target }.each(&:remove_from_project)
    other.copy_files_build_phases.each do |phase|
      phase.files.select { |f| f.file_ref == target.product_reference }.each(&:remove_from_project)
    end
  end
end

targets.each do |target|
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
       .select { |c| NAMES.include?(c.display_name) && c.is_a?(Xcodeproj::Project::Object::PBXGroup) }
       .each { |g| remove_group(g) }

# An SDK-pinned Foundation.framework group, which early versions of
# add_watch_target.rb left behind.
project.frameworks_group.children
       .select { |g| g.display_name == "watchOS" && g.is_a?(Xcodeproj::Project::Object::PBXGroup) }
       .each { |g| remove_group(g) }

project.save

Dir.glob(File.join(PROJECT_PATH, "xcshareddata", "xcschemes", "DoxaWatch-*.xcscheme"))
   .each { |path| FileUtils.rm(path) }

puts targets.empty? ? "The watch app was not in Runner.xcodeproj." : "Removed #{targets.map(&:name).join(' and ')} from Runner.xcodeproj."
