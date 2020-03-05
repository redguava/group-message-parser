require 'thor'

class Parser < Thor
  desc "import", "Import mail files in DIR to sqlite database DB"
  option :dir, required: true, type: :string, desc: "Directory where mail files can be found"
  option :db, required: false, default: 'messages.db', type: :string, desc: "Filename of output database"
  option :cutoffdate, required: false, type: :string, desc: "Message cutoff date. Messages older than this will not be imported"
  option :ignore, required: false, default: '', type: :string, desc: "Comma-separated list of email domains to ignore"
  option :group, required: false, default: 'default', type: :string, desc: "Name of imported group"

  def import
    directory = options[:dir]
    db_path = options[:db]
    group_name = options[:group]
    cutoff_date = options[:cutoffdate]
    ignore = options[:ignore]

    if ignore
      ignore = ignore.split(',').map do |domain|
        "@#{domain.strip}"
      end
    else
      ignore = []
    end

    target_date = Time.parse(cutoff_date)
    require 'group_parser'

    db = GroupParser::Repository::Message.new(File.absolute_path(db_path, Dir.pwd))
    db.setup

    GroupParser.parse_messages(directory).each_slice(1000) do |messages|
      db.with_transaction do
        messages.each do |message|
          next if message.date < target_date
          ignore.each do |domain|
            next if message.from_email.include?(domain)
          end

          db.store(message, group_name)
        rescue => e
          puts message.id

          raise
        end
      end
    end
  end

  desc "import_contacts", "Import intercom contacts from CONTACTS"
  option :contacts, required: true, type: :string, desc: "File containing intercom contacts"
  option :db, required: false, default: 'messages.db', type: :string, desc: "Filename of output database"

  def import_contacts
    contacts_path = options[:contacts]
    db_path = options[:db]

    contact_file = File.realpath(contacts_path, Dir.pwd)

    require 'group_parser'

    db = GroupParser::Repository::Contact.new(File.absolute_path(db_path, Dir.pwd))
    db.setup

    IO.foreach(contact_file).each_slice(500) do |contacts|
      addresses = contacts.reject do |contact|
        contact.include?('@cliniko.com')
      end.map do |contact|
        contact.strip
      end.reject(&:empty?)

      db.store(addresses)
    end
  end
end
