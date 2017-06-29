class CC::Service::Campfire < CC::Service
  class Config < CC::Service::Config
    attribute :subdomain, Axiom::Types::String,
      description: "The Campfire subdomain for the account"
    attribute :token, Axiom::Types::Token,
      description: "Your Campfire API auth token"
    attribute :room_id, Axiom::Types::String,
      description: "Check your campfire URL for a room ID. Usually 6 digits."

    validates :subdomain, presence: true
    validates :room_id, presence: true
    validates :token, presence: true
  end

  self.description = "Send messages to a Campfire chat room"

  def receive_test
    speak(formatter.format_test).merge(
      message: "Test message sent",
    )
  end

  def receive_coverage
    speak(formatter.format_coverage)
  end

  def receive_quality
    speak(formatter.format_quality)
  end

  def receive_vulnerability
    speak(formatter.format_vulnerability)
  end

  private

  def formatter
    CC::Formatters::PlainFormatter.new(self)
  end

  def speak(line)
    http.headers["Content-Type"] = "application/json"
    params = { message: { body: line } }

    http.basic_auth(config.token, "X")
    service_post(speak_uri, params.to_json)
  end

  def speak_uri
    subdomain = config.subdomain
    room_id = config.room_id
    "https://#{subdomain}.campfirenow.com/room/#{room_id}/speak.json"
  end
end
