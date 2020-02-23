require 'mail'

module GroupParser
  class MessageParsingError < StandardError; end

  class Message
    attr_accessor :body, :date, :from, :from_email, :id, :subject,

    def self.read_file(filename)
      mail = Mail.read(filename)

      raise MessageParsingError.new("Could not parse #{filename}") unless mail
      raise MessageParsingError.new("Could not identify sender in #{filename}") unless mail.from

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

      if mail[:from].respond_to? :formatted
        self.from = mail[:from].formatted.first
      else
        self.from = mail[:from].default
      end

      if mail.from.respond_to? :first
        self.from_email = mail.from.first
      else
        # possible parsing error
        permissive_mail_regex = /[a-z0-9!#$%&'*+\/=?^_‘{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_‘{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/
        match = permissive_mail_regex.match(mail.from)
        self.from_email = match.captures.first if match
      end

      self.subject = mail.subject

      body = find_body(mail)
      self.body = body.to_s.gsub(/\t+/, "\t").gsub(/(\r\n)+/, "\r\n") if body

      id = /\Am\.(.+?\..+)/.match(File.basename(filename))
      self.id = id.captures.first.sub(/\./, '/') if id
    end

    def inspect
      <<~INSPECT
      <Mail
        id: #{self.id}
        date: #{self.date}
        from: #{self.from}
        subject: #{self.subject}
        body: #{self.body.length} char
      >
      INSPECT
    end


    private

    def find_body(mail)
      if ! mail.multipart?
        return mail.body
      end

      plaintext_body = mail.parts.find { |part| part.content_type.include?('text/plain') }
      return plaintext_body if plaintext_body

      # try to find the first plaintext sub-part (one level deep)
      return mail.parts.select(&:multipart?).flat_map(&:parts).find {|part| part.content_type.include?('text/plain') }
    end
  end
end
