class City < ActiveRecord::Base
  has_many :neighborhoods
  has_many :listings, :through => :neighborhoods

  def city_openings(d1,d2)
    self.listings.select do |listing|
      listing.reservations.select do |reservation|
        (reservation.checkin > Date.parse(d1) && reservation.checkin < Date.parse(d2)) ||         (reservation.checkout > Date.parse(d1) && reservation.checkout < Date.parse(d2)) ||
        (reservation.checkin <= Date.parse(d1) && reservation.checkout >= Date.parse(d2))
      end.empty?
    end
  end

  def self.highest_ratio_res_to_listings
    ratios = City.all.inject({}) do |city_ratio, city|
      listing_count = city.listings.count
      total_reservations = city.listings.inject(0) do |output, listing|
        output + listing.reservations.count
      end

      # total_reservations = 0
      # city.listings.each do |listing|
      #   total_reservations += listing.reservations.count
      # end
      city_ratio[city.name] = total_reservations/listing_count
      city_ratio
    end
    City.find_by(name: ratios.key(ratios.values.max))
  end

  # def self.most_res
  #   city_reservations = Hash.new(0)
  #   City.all.map do |city|
  #     total_reservations = 0
  #     city.listings.each do |listing|
  #       total_reservations += listing.reservations.count
  #     end
  #     city_reservations[city.name] += total_reservations
  #   end
  #   City.find_by(name: city_reservations.key(city_reservations.values.max))
  # end

  def self.most_res
    city_reservations = City.all.inject(Hash.new(0)) do |output, city|
      total_reservations = city.listings.inject(0) do |reservs, listing|
        reservs += listing.reservations.count
      end
      output[city.name] += total_reservations
      output
    end
    City.find_by(name: city_reservations.key(city_reservations.values.max))
  end

end
