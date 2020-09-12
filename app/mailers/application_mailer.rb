class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
  
  
  # 開催日時を返す
  def to_date_and_time(date, datetime)
    @date = date
    @datetime = datetime
    @start_datetime = Time.new(@date.year, @date.month, @date.day, @datetime.hour, 
                        @datetime.min, 0, "+09:00")
    return @start_datetime
  end
  
  # 日本語表記の曜日を返す
  def day_of_the_week(number)
    weeks = ["月","火","水","木","金","土","日"]
    @day_of_the_week = "（" + weeks[number.to_i - 1] + "）"
    return @day_of_the_week
  end
end
