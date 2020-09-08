module ApplicationHelper
  
  # 各ページのタイトル設定
  def full_title(page_title = ' ')
    base_title = 'Realtime Social'
    if page_title.empty?
      base_title
    else
      page_title + ' ｜ ' + base_title
    end
  end
  
  # メタディスクリプション設定
  # メタtag
  def meta_discription(page_content = '')
    base_content = 'オンラインで飲み会が可能です！'
    if page_content.empty?
      base_content
    else
      page_content + '｜' + base_content
    end
  end
  
  # boolean変換メソッド
  def to_bool(func)
    if func == "true"
      return true
    elsif func == "false"
      return false
    end
  end
  
  # 開催日時を返す
  def to_date_and_time(date, datetime)
    @date = date
    @datetime = datetime
    @start_datetime = Time.new(@date.year, @date.month, @date.day, @datetime.hour, 
                        @datetime.min, 0, "+09:00")
    return @start_datetime
  end
  
end
