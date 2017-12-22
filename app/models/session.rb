class Session < ApplicationRecord
  has_secure_token
  belongs_to :app
  belongs_to :user

  validates :app_id, presence: true
  validates :user_id, presence: true
  validates :token, presence: true

  before_save :process_user_agent

  @@ua_parser = UserAgentParser::Parser.new

  def matches_request(request)
    parse_user_agent(request.user_agent) == [device, operating_system, browser]
  end

  def parse_user_agent(ua = nil)
    ua = @@ua_parser.parse(ua || user_agent)
    # device, operating_system, browser
    [ua.device.to_s, ua.os.to_s, ua.family]
  end

  def process_user_agent
    device, os, browser = parse_user_agent
    self.device = device
    self.operating_system = os
    self.browser = browser
  end

  def attributes_for_api
    {'id' => unique_id}.merge(self.slice(:user_agent, :device, :operating_system, :browser, :last_ip, :created_at))
  end

  def pulic_attributes_for_api
    raise 'sessions are not public'
  end

  def digest
    @digest ||= Digest::SHA256.hexdigest([id, token, app_id, user_id, device_id, device, operating_system, browser].to_json)
  end
end
