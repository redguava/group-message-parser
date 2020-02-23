require 'group_parser/message'

module GroupParser
  def self.parse_messages(directory)
    return to_enum(__method__, directory) unless block_given?

    Dir.foreach(directory) do |filename|
      next if (filename == '.' || filename == '..')

      path = File.realpath(filename, directory)
      next unless File.file?(path)

      yield Message.read_file(path)
    rescue => e
      puts path
      raise
    end
  end
end
