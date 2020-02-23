require 'thor'

class Parser < Thor
  desc "import", "Import mail files in DIR to sqlite database DB"
  option :dir, required: true, type: :string, desc: "Directory where mail files can be found"
  option :db, required: false, default: 'messages.db', type: :string, desc: "Filename of output database"

  def import
    directory = options[:dir]
    db = options[:db]

    target_date = Time.parse('2017-11-20')
    require 'group_parser'
    GroupParser.parse_messages(directory) do |message|
      next if message.date < target_date
      next if message.from.include?('@cliniko.com')
    end
  end
end
