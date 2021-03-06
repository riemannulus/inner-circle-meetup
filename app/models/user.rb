class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable

  def self.find_for_oauth(auth)
    user = User.where(uid: auth.uid, provider: auth.provider).first

    unless user
      user = User.create(
        uid:      auth.uid,
        provider: auth.provider,
        email:    User.dummy_email(auth),
        password: Devise.friendly_token[0, 20],
        name: auth.info.name,
        nickname: auth.info.nickname,
        token: auth.credentials.token,
        secret: auth.credentials.secret
      )
    end

    user
  end

  def client
    @_client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_APP_KEY']
      config.consumer_secret = ENV['TWITTER_APP_SECRET']
      config.access_token = self.token
      config.access_token_secret = self.secret
    end
  end

  private

  def self.dummy_email(auth)
    "#{auth.uid}-#{auth.provider}@example.com"
  end
end
