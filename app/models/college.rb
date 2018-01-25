# frozen_string_literal: true

# Model for site configuration / individual colleges. Will be used for
# multi-tenancy in the future.
#
# @attr name [String] the college name
# @attr admin_email [String] the admin e-mail for the college
# @attr dean [String] the name of the college dean / head
# @attr site_url [String] the full url (including http/https) for the Vesta site
#   for the college
# @attr floor_plan_url [String] the url to access floor plans
# @attr student_info_text [Text] a paragraph of text viewable on the student
#   dashboard
# @attr users [Array<User>] all of the users in the college
class College < ApplicationRecord
  has_many :users

  validates :name, presence: true
  validates :admin_email, presence: true
  validates :dean, presence: :true
  validates :site_url, presence: :true
  validates :subdomain, uniqueness: { case_sensitive: false }

  before_validation :set_subdomain
  after_create :create_schema!

  # Returns the current Apartment tenant. Returns a null object (blank college)
  # if tenant does not exist (shouldn't be possible unless we're in the public
  # schema.
  #
  # @return [College] the current college or a null college
  def self.current
    find_by!(subdomain: Apartment::Tenant.current)
  rescue ActiveRecord::RecordNotFound
    new
  end

  def create_schema!
    Apartment::Tenant.create(subdomain)
  end

  def activate!
    Apartment::Tenant.switch!(subdomain)
  end

  private

  def set_subdomain
    return if subdomain.present?
    assign_attributes(subdomain: URI.encode_www_form_component(name&.downcase))
  end
end
