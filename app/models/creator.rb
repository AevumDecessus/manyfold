class Creator < ApplicationRecord
  include Followable
  include Caber::Object
  include DefaultViewPermissions

  can_grant_permissions_to User
  can_grant_permissions_to Role

  acts_as_federails_actor username_field: :slug, name_field: :name, profile_url_method: :url_for, include_in_user_count: false

  has_many :models, dependent: :nullify
  has_many :links, as: :linkable, dependent: :destroy
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  validates :name, uniqueness: {case_sensitive: false}
  validates :slug, uniqueness: true

  default_scope { order(:name) }

  before_validation :slugify_name, if: :name_changed?

  def self.ransackable_attributes(_auth_object = nil)
    ["caption", "created_at", "id", "name", "notes", "slug", "updated_at"]
  end

  def self.ransackable_associations(_auth_object = nil)
    ["links", "models"]
  end

  private

  def slugify_name
    self.slug = name.parameterize
  end
end
