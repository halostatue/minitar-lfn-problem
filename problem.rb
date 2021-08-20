require "minitar"

tar_source = "tar_source"
tar_extracted = "tar_extracted"

Dir.chdir(tar_source) do
  Minitar.pack(".", File.open("../archive.tar", "wb"))
end

FileUtils.rm_r(tar_extracted) if File.directory?(tar_extracted)
Minitar.unpack(File.open("archive.tar", "rb"), tar_extracted)

files_in_source = Dir.chdir(tar_source) { Dir["**/*"].sort }
files_in_dest = Dir.chdir(tar_extracted) { Dir["**/*"].sort }

source_only = files_in_source - files_in_dest

puts "Files only present in source dir:"
source_only.each { |name| puts "  #{name }" }

