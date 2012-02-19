class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  #
  # Attributes
  #
  field :admin,                type: Boolean, default: false
  field :name,                 type: String
  field :facebook_uid,         type: String
  field :facebook_token,       type: String
  attr_accessible :name, :email, :password, :password_confirmation,
    :remember_me, :facebook_uid, :facebook_token
  index :facebook_uid

  #
  # Validations
  #
  validates_presence_of :name

  #
  # Associations
  #
  has_and_belongs_to_many :elections

  #
  # Callbacks
  #
  before_create :reset_authentication_token

  def self.find_for_facebook_token access_token
    begin
      graph   = Koala::Facebook::API.new(access_token)
      profile = graph.get_object("me")
    rescue Koala::Facebook::APIError => e
      return
    end
    return unless profile['email'].present?

    if user = User.where(facebook_uid: profile['id']).first
      # Do nothing
    elsif user = User.where(email: profile['email']).first
      # Do nothing
    else
      user = User.new facebook_uid: profile['id'],
        password: Devise.friendly_token[0,20]
    end

    user.facebook_token = access_token
    user.email = profile['email']
    user.name  = profile['name']

    user.save ? user : nil
  end
  
  # picture
  def picture?
    !facebook_uid.blank?
  end
  
  def picture
    "http://graph.facebook.com/#{facebook_uid}/picture?type=square"
  end

end
