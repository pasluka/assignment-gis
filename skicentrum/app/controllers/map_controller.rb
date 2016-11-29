class MapController < ActionController::Base
  layout 'application'

  def show
    @regions = Region.all.order(:name)
    @facilities = [{"id"=> "ski_schools", "name" => "Ski schools"},{"id" => "ski_rentals", "name" => "Ski rentals"},{"id" => "accomodation", "name" => "Acommodation"}]

  end
end