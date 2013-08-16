class Alert < ActiveRecord::Base
  belongs_to :user
  validates :user, :query, :name, :presence => true
end
