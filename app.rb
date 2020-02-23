require 'thor'

class Parser < Thor
  desc "import", "Import mail files in DIR to sqlite database DB"
  option :dir, required: true, type: :string, desc: "Directory where mail files can be found"
  option :db, required: false, default: 'messages.db', type: :string, desc: "Filename of output database"

  def import
    directory = options[:dir]
    db_path = options[:db]

    target_date = Time.parse('2017-11-20')
    require 'group_parser'

    db = GroupParser::Repository.new(File.absolute_path(db_path, Dir.pwd))
    db.setup

    GroupParser.parse_messages(directory).each_slice(1000) do |messages|
      db.with_transaction do
        messages.each do |message|
          next if message.date < target_date
          next if message.from_email.include?('@cliniko.com')

          db.store(message)
        rescue => e
          puts message.id

          raise
        end
      end
    end
  end
end
