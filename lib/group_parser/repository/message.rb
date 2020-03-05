require 'group_parser/repository'

module GroupParser::Repository
  class Message < Base
    def setup
      @db.execute_batch <<-SQL
        PRAGMA journal_mode = MEMORY;

        CREATE TABLE IF NOT EXISTS messages (
          id TEXT PRIMARY KEY,
          date INTEGER,
          from_display TEXT,
          from_address TEXT,
          subject TEXT,
          body TEXT,
          group_name TEXT
        );
        CREATE INDEX IF NOT EXISTS from_index
          ON messages (from_address);

        CREATE INDEX IF NOT EXISTS date_index
          ON messages (date ASC);

        CREATE INDEX message_type_index
          ON messages (group_name);

        CREATE TABLE IF NOT EXISTS meta (
          version INTEGER PRIMARY KEY
        );

        INSERT INTO meta (version)
          SELECT 1
          WHERE NOT EXISTS (SELECT version FROM meta WHERE version = 1);
      SQL

      migrate
    end

    def migrate
    end

    def store(message, group_name)
      query = <<-SQL
        INSERT INTO messages (id, date, from_display, from_address, subject, body, group_name)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT (id) DO NOTHING
      SQL
      @db.execute(query, [message.id, message.date.to_i, message.from, message.from_email, message.subject, message.body, group_name])
    end
  end
end
