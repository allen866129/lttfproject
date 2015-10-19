#encoding: UTF-8”
class User < ActiveRecord::Base
  after_create  :assign_default_photo ,:create_profile 
  after_commit :assign_default_role
  validates :username, presence: true
  validates :username, uniqueness: true, if: -> { self.username.present? }
  validate :username_without_
  validate :fbaccount_without_email
  validates_format_of :email,:with => Devise.email_regexp
  rolify

    
  #after_create :create_child
  def email_required?
  false
  end

 def email_changed?
  false
 end


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable ,:omniauthable
  has_one :playerprofile, dependent: :destroy
  has_one :gameholder, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  attr_accessible :id, :username, :email, :fbaccount, :password, :password_confirmation, :remember_me,:playerphoto ,:playerprofile_attributes
   attr_accessible :phone
  attr_accessible :role_ids
  accepts_nested_attributes_for :playerprofile   
  mount_uploader :playerphoto, PlayerPhotoUploader 
  
def assign_default_role
    self.add_role(:member) if self.roles.blank?
end

def create_profile
  self.build_playerprofile if !self.playerprofile
end  
def assign_default_photo
    if !self.playerphoto
    file_path="#{Rails.root}/public/LTTF_logo.png"  
    self.playerphoto = File.open(file_path)
    self.save
  end
end
  def self.new_with_session(params,session)

    if session["devise.user_attributes"]
      new(session["devise.user_attributes"],without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def self.from_omniauth(auth, current_user)
    #authorization = Authorization.where(:provider => auth.provider, :uid => auth.uid.to_s, :token => auth.credentials.token, :secret => auth.credentials.secret).first_or_initialize
    authorization = Authorization.where(:provider => auth.provider, :uid => auth.uid.to_s).first_or_initialize

    if authorization.user.blank?
       user = current_user.nil? ? User.where(:fbaccount =>auth["info"]["name"], :email=>auth["info"]["email"]).first : current_user
     
      if !user || (user.blank?) || (current_user && user.username!=current_user.username)
        return nil
      else    #authorization.username = auth.info.nickname
        authorization.user_id = user.id
      end 
    end 
    if !current_user || (authorization.user ==current_user)
       authorization.token = auth.credentials.token
       authorization.secret = auth.credentials.secret
       authorization.save
       authorization.user
    else
     return nil 
    end   
     
  end
  def self.order_by_ids(ids)
   order_by = ["case"]
  ids.each_with_index.map do |id, index|
    order_by << "WHEN id='#{id}' THEN #{index}"
  end
  order_by << "end"
  order(order_by.join(" "))
end
  def find_reg_unplay_games
      attendants=Attendant.where(:player_id=>self.id)
      attendants=Attendant.where(:player_id=>self.id).find_all{|v| ( v.groupattendant.gamegroup.holdgame) && (v.groupattendant.gamegroup.holdgame.startdate>= Time.zone.now.to_date) }
      return [] if attendants.empty?
      @games=Array.new
      attendants.each do |attendant|
        @games.push(attendant.groupattendant.gamegroup.holdgame)
      end
      return @games.sort_by { |hsh| hsh[:startdate] }.uniq
  end  
 private
    def username_without_
     
       errors.add(:username, "姓名不得含有\"_\"字元請重新輸入，請用\"-\"字元取代\"_\"字元 ") unless read_attribute(:username).to_s.exclude? "_"  
      
    end
    def fbaccount_without_email
      errors.add(:fbaccount, "FB帳號不可使用email，請使用FB上的名字") unless read_attribute(:fbaccount).to_s.exclude? "@"  
    end  
end
