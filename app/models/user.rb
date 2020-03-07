class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  validates :username, presence: :true, uniqueness: { case_sensitive: false }, length: { minimum: 1, maximum: 20 }
  validates_format_of :username, with: /\A[a-zA-Z0-9_\.]+\z/

  has_one :teacher_profile, class_name: 'Teacher'
  has_many :courses, foreign_key: 'student_id'

  has_many :tickets

  attr_writer :login

  after_create do
    new_account_free_ticket = self.tickets.new(initial_count: 1, remaining: 1)
    new_account_free_ticket.save
  end

  def login
    @login || self.username || self.email
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      if conditions[:username].nil?
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end

  def use_ticket(ticket_count=1)
    ticket = self.tickets.valid.order("expiration ASC NULLS LAST").first
    ticket.remaining -= ticket_count
    ticket.save
  end

  def add_tickets(ticket_count, expiration=nil)
    tickets = self.tickets.new(initial_count: ticket_count, remaining: ticket_count, expiration: expiration)
    tickets.save
  end

  def remaining_tickets
    self.tickets.valid.sum('remaining')
  end

  def tickets_validity
    self.tickets.valid.group(:expiration).order(expiration: :desc).pluck(:expiration, 'SUM(remaining)')
  end
end
