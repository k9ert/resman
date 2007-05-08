# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def date_string date
    date.strftime("%d.%m.%Y")
  end

  def time_string time
    time.strftime("%H:%M")
  end
end
