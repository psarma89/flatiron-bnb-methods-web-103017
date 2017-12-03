class Neighborhood < ActiveRecord::Base
  belongs_to :city
  has_many :listings

  def neighborhood_openings(d1,d2)
    self.listings.select do |listing|
      listing.reservations.select do |reservation|
        (reservation.checkin > Date.parse(d1) && reservation.checkin < Date.parse(d2)) ||         (reservation.checkout > Date.parse(d1) && reservation.checkout < Date.parse(d2)) ||
        (reservation.checkin <= Date.parse(d1) && reservation.checkout >= Date.parse(d2))
      end.empty?
    end
  end

  def self.highest_ratio_res_to_listings
    ratios = Neighborhood.all.inject({}) do |neighborhood_ratio, neighborhood|
      listing_count = neighborhood.listings.count
      total_reservations = neighborhood.listings.inject(0) do |output, listing|
        output + listing.reservations.count
      end
      if listing_count == 0
        neighborhood_ratio[neighborhood.name] = 0
      else
        neighborhood_ratio[neighborhood.name] = total_reservations.to_f/listing_count.to_f
      end
      neighborhood_ratio
    end
    Neighborhood.find_by(name: ratios.key(ratios.values.max))
  end

  # def self.most_res
  #   neighborhood_reservations = Hash.new(0)
  #   neighborhood.all.map do |neighborhood|
  #     total_reservations = 0
  #     neighborhood.listings.each do |listing|
  #       total_reservations += listing.reservations.count
  #     end
  #     neighborhood_reservations[neighborhood.name] += total_reservations
  #   end
  #   neighborhood.find_by(name: neighborhood_reservations.key(neighborhood_reservations.values.max))
  # end

  def self.most_res
    neighborhood_reservations = Neighborhood.all.inject(Hash.new(0)) do |output, neighborhood|
      total_reservations = neighborhood.listings.inject(0) do |reservs, listing|
        reservs += listing.reservations.count
      end
      output[neighborhood.name] += total_reservations
      output
    end
    Neighborhood.find_by(name: neighborhood_reservations.key(neighborhood_reservations.values.max))
  end

end
