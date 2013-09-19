module SequencingsHelper

  def format_date(date)
    Date::ABBR_MONTHNAMES[date.month] + " " + 
      date.day.ordinalize + " " + 
      date.year.to_s
  end
end
