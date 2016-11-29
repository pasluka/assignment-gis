require 'skiresort'

class SkieurController < ActionController::Base

  def ski_resorts
    @ski_resorts = SkiResort.all_resorts ski_resorts_params
  end


  def ski_resorts_reg
    @ski_resorts = SkiResort.resorts_in_region ski_resorts_region_params
  end

  def ski_resorts_fac
    @ski_resorts = SkiResort.all_resorts ski_resorts_facilities_params
    @facilities = SkiResort.all_facilities ski_resorts_facilities_params
  end

  def ski_resorts_fac_reg
    @ski_resorts = SkiResort.resorts_in_region ski_resorts_advanced_params
    @facilities = SkiResort.all_facilities_in_region ski_resorts_advanced_params
  end


  private

  def ski_resorts_params
    params.permit :minlat, :minlng, :maxlat, :maxlng, :minElev, :maxElev
  end

  def ski_resorts_region_params
    params.permit :minlat, :minlng, :maxlat, :maxlng, :minElev, :maxElev, :region
  end

  def ski_resorts_facilities_params
    params.permit :minlat, :minlng, :maxlat, :maxlng, :minElev, :maxElev, :facility, :distance
  end

  def ski_resorts_advanced_params
    params.permit :minlat, :minlng, :maxlat, :maxlng, :minElev, :maxElev, :region, :facility, :distance
  end

  def ski_resorts_near_accomodation_params

  end
end