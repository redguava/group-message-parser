require 'sqlite3'

module GroupParser::Repository
  class Base
    def initialize(path)
      @db = SQLite3::Database.new path
    end

    def setup; end

    def with_transaction
      @db.execute('begin')
      yield
      @db.execute('end')
    end
  end
end
