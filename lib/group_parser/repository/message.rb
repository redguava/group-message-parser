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
          body TEXT
        );
        CREATE INDEX IF NOT EXISTS from_index
          ON messages (from_address);

        CREATE INDEX IF NOT EXISTS date_index
          ON messages (date ASC);
      SQL
    end

    def store(message)
      query = <<-SQL
        INSERT INTO messages (id, date, from_display, from_address, subject, body)
        VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT (id) DO NOTHING
      SQL
      @db.execute(query, [message.id, message.date.to_i, message.from, message.from_email, message.subject, message.body])
    end
  end
end
