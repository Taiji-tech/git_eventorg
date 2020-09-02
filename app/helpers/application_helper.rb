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
    
end
