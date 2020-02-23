require 'group_parser/message'

module GroupParser
  def self.parse_messages(directory)
    Dir.foreach(directory) do |filename|
      next if (filename == '.' || filename == '..')

      path = File.realpath(filename, directory)
      next unless File.file?(path)

      yield Message.read_file(path)
    rescue => e
      puts e
      puts path
      raise
    end
  end
end
