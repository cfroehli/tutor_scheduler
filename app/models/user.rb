# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       length: { minimum: 1, maximum: 20 }, format: /\A[a-zA-Z0-9_.]+\z/

  has_one :teacher_profile, class_name: 'Teacher', dependent: :destroy
  has_many :courses, foreign_key: 'student_id', inverse_of: :student, dependent: :destroy

  has_many :tickets, dependent: :destroy

  after_create do
    # New user got free tickets to try our service
    tickets.create(initial_count: 1, remaining: 1)

    # Default to 'user' role
    add_role(:user)
  end

  attr_writer :login

  def login
    @login || username || email
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).find_by(['lower(username) = :value OR lower(email) = :value', { value: login.downcase }])
  end

  def has_stripe_subscription
    stripe_subscription_id.present?
  end

  def set_stripe_subscription(subscription_id, plan_id)
    self.stripe_subscription_id = subscription_id
    self.stripe_plan_id = plan_id
    save
  end

  def use_ticket
    self.transaction do
      ticket = tickets.valid.order('expiration ASC NULLS LAST').first
      ticket.remaining -= 1
      ticket.save
    end
  end

  def add_tickets(ticket_count, expiration = nil)
    expiration = Time.zone.at(expiration) if expiration
    tickets.create(initial_count: ticket_count, remaining: ticket_count, expiration: expiration)
    save
  end

  def remaining_tickets
    tickets.valid.sum('remaining')
  end

  def tickets_validity
    tickets.valid.group(:expiration).order(expiration: :desc).pluck(:expiration, 'SUM(remaining)')
  end

  def ensure_teacher_profile
    return teacher_profile if teacher_profile

    self.create_teacher_profile(name: username, presentation: 'Present yourself here...')
  end
end
