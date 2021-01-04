class StaticPageController < ApplicationController
  
  # お問い合わせページ
  def contact
    @contact = Contact.new
  end
  
  # お問い合わせアクション
  def contact_for_admin
    @contact = Contact.new(contact_params)
    if @contact.save
      ContactMailer.mail_for_admin(@contact).deliver_now
      ContactMailer.mail_for_user(@contact).deliver_now
      render :contact_for_admin
    else
      render :contact
    end
  end
  
  def tokushohyo
  end
  
  def privacy
  end
  
  def term
  end
  
      private 
        def contact_params
          params.require(:contact).permit(:name, :email, :title, :content)
        end
        

  
end
