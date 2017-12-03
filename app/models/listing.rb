class Listing < ActiveRecord::Base
  belongs_to :neighborhood
  belongs_to :host, :class_name => "User"
  has_many :reservations
  has_many :reviews, :through => :reservations
  has_many :guests, :class_name => "User", :through => :reservations

  validates :address, :listing_type, :title, :description, :price, :neighborhood_id, presence: :true

  after_save :make_host
  before_destroy :update_host

  def average_review_rating
    (self.reviews.inject(0){|sum,review| sum + review.rating}).to_f / (self.reviews.size).to_f
  end

  private

  def make_host
    self.host.host = true
    self.host.save
  end

  def update_host
    if self.host.listings.count == 1
      self.host.host = false
      self.host.save
    end
  end

end
