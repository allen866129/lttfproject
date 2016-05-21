class HomeController < ApplicationController
   layout :resolve_layout

  def index
  	@ttcoutrs_count= Ttcourt.count
  end
  def resolve_layout
  	 "lttfhome"
  end
  
end
