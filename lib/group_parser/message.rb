require 'mail'

module GroupParser
  class Message
    attr_accessor :body, :date, :from, :from_email, :id, :subject,

    def self.read_file(filename)
      mail = Mail.read(filename)
      new(mail, filename)
    end

    def self.save(message)
      #TODO
    end

    def initialize(mail, filename)
      parse(mail, filename)
    end

    def parse(mail, filename)
      self.date = mail.date.to_time.utc
      self.from = mail[:from].formatted.first
      self.from_email = mail.from.first
      self.subject = mail.subject

      body = if mail.multipart?
        mail.parts.find { |part| part.content_type.include?('text/plain') }.body.to_s
      else
        mail.body
      end

      self.body = body.gsub(/\t+/, "\t").gsub(/(\r\n)+/, "\r\n")

      id = /\Am\.(.+?\..+)/.match(File.basename(filename))
      self.id = id.captures.first.sub(/\./, '/') if id
    end

    def inspect
      <<~INSPECT
      <Mail
        id: #{@id}
        date: #{@date}
        from: #{@from_email}
        subject: #{@subject}
        body: #{@body.length} char
      >
      INSPECT
    end
  end
end
