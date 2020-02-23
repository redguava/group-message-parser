require 'group_parser/repository'

module GroupParser::Repository
  class Contact < Base
    def setup
      @db.execute_batch <<-SQL
        PRAGMA journal_mode = MEMORY;

        CREATE TABLE IF NOT EXISTS contacts (
          email TEXT PRIMARY KEY
        );
      SQL
    end

    def store(addresses)
      return if addresses.empty?

      value_sql = ('(?),' * addresses.count).delete_suffix(',')
      query = <<-SQL
        INSERT INTO contacts (email)
        VALUES #{value_sql}
        ON CONFLICT (email) DO NOTHING
      SQL

      @db.execute(query, addresses)
    end
  end
end
