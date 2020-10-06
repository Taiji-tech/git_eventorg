class PaysController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :confirmCard, :editCard, :updateCard, :profit, 
                                            :hostNew, :hostCreate, :hostInfo, :hostEdit, :hostUpdate]
  before_action :user_info, only: [:new, :create, :confirmCard, :editCard, :updateCard, :profit, 
                                   :hostNew, :hostCreate, :hostInfo, :hostEdit, :hostUpdate]
  before_action :store_location, only: [:newWithoutResistration, :new, :confirmCard, :editCard, :profit, :hostNew, :hostEdit, :hostInfo]
  before_action :register_bank_account, only: [:profit]
  
  # http通信実装のためのライブラリ
  require 'net/https'
  require 'uri'
  
  # payjp API用
  require 'payjp'
  
  # カード登録がない状態で支払いを行う表示
  def newWithoutResistration
    if params[:reserve_id].present?
      @reserve = Reserve.find(params[:reserve_id])
      @event = Event.find(@reserve.event_id)
    end
    @pay = Pay.new
  end
  
  # カード登録がない状態で支払い
  def createWithoutResistration
    @reserve = Reserve.find(params[:reserve_id])
    @event = Event.find(@reserve.event_id)
    @tenant = Tenant.find_by(user_id: @event.user_id)
    
    if params["payjp-token"].present?
      pay_action_createWithoutResistration
    else 
      flash[:notice] = "お支払い情報が入力されていません"
      redirect_to session[:privious_url]
    end
  end
  
  # カード情報の新規登録
  def new
    @card = Card.find_by(user_id: current_user.id)
  end
  
  # クレカ情報の登録
  def create
    Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
    if params['payjp-token'].blank?
      flash.now[:notice] = "カード情報が入力されていません。"
      render :new
    else
      begin 
        @customer = Payjp::Customer.create(
          card: params['payjp-token']
        )
        @card = Card.new(user_id: current_user.id, customer_id: @customer.id, card_id: @customer.default_card)
        @card.save
        PayMailer.mail_credit_registered(@user).deliver_now
        redirect_to user_pays_confirm_card_path
        payjp_rescue
      end
    end
  end
  
  # カード情報の確認
  def confirmCard
    @card = Card.find_by(user_id: current_user.id)
    credit_card_info
  end
  
  # カード情報の編集
  def editCard
    @card = Card.find_by(user_id: current_user.id)
    credit_card_info
  end
  
  # カード情報の更新
  def updateCard
     Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
    if params['payjp-token'].blank?
      flash.now[:notice] = "カード情報が入力されていません。"
      render :editCard
    else
      begin
        @card = Card.find_by(user_id: current_user.id)
        customer = Payjp::Customer.retrieve(@card.customer_id)
        @customer = customer.cards.create(
          card: params['payjp-token'],
          default: true
        )
        @card.update(card_id: @customer.id)
        PayMailer.mail_credit_updated(@user).deliver_now
        flash[:notice] = 'クレジットカード情報が更新されました。'
        redirect_to user_pays_confirm_card_path
      rescue Payjp::CardError => e
        flash[:notice] = 'カード情報の取得ができませんでした。'
        redirect_to session[:previous_path]
      rescue Payjp::InvalidRequestError => e
        flash[:notice] = '不正なパラメータが入力されました。'
        redirect_to session[:previous_path]
      rescue Payjp::AuthenticationError => e
        flash[:notice] = 'カード情報の取得ができませんでした。'
        redirect_to session[:previous_path]
      rescue Payjp::APIConnectionError => e
        flash[:notice] = '通信エラーが発生しました。もう一度登録をしてください。'
        redirect_to session[:previous_path]
      rescue Payjp::APIError => e
        flash[:notice] = '通信エラーが発生しました。もう一度登録をしてください。'
        redirect_to session[:previous_path]
      rescue Payjp::PayjpError => e
        flash[:notice] = 'カード情報の取得ができませんでした。'
        redirect_to session[:previous_path]
      rescue StandardError
        flash[:notice] = 'エラーが発生しました。もう一度登録してください。'
        redirect_to session[:previous_path]
      end
    end
  end
  
  # 売り上げ確認
  def profit
    payjp_transfer_info
  end
  
  # イベントホストの銀行口座情報入力
  def hostNew
    @tenant = Tenant.find_by(user_id: current_user.id)
  end
  
  # イベントホストのカード情報登録
  def hostCreate
    if params[:bank_code].present? && params[:bank_branch_code].present? && params[:bank_account_type].present? &&
      params[:bank_account_number].present? && params[:bank_account_holder_name].present?  
      begin
        # payjp通信
        payjp_create_tenant
        if @tenant_id.present?
          @tenant = Tenant.new(user_id: current_user.id, tenant_id: @tenant_id)
          @tenant.save
          PayMailer.mail_bank_registered(@user).deliver_now
          flash[:notice] = "銀行口座登録が完了しました！"  
          redirect_to user_pays_hostinfo_path
        else
          flash[:notice] = "入力された銀行口座情報に誤りがあります。お手数ですがもう一度入力してください。"
          redirect_to session[:previous_path]
        end
      rescue 
        flash[:notice] = "入力した情報に不備があります。再度入力してください"    
        render :hostNew
      end
    else
    # 入力情報が空の場合
      flash[:notice] = "空欄の項目があります。すべて入力してください。"    
      render :hostNew
    end
  end
  
  # ホストが登録しているカード情報確認
  def hostInfo
    payjp_confirm_tenant
  end
  
  # ホストが登録しているカード情報の編集
  def hostEdit
    payjp_confirm_tenant
  end
  
  # ホストが登録しているカード情報の更新
  def hostUpdate
    if params[:bank_code].present? && params[:bank_branch_code].present? && params[:bank_account_type].present? &&
      params[:bank_account_number].present? && params[:bank_account_holder_name].present?  
      begin
        # payjp通信
        payjp_update_tenant
        PayMailer.mail_bank_updated(@user).deliver_now
        flash[:notice] = "口座情報を更新しました！" 
        redirect_to user_pays_hostinfo_path
      rescue 
        flash[:notice] = "入力された情報に不備があります。再度入力してください"    
        render :hostNew
      end
    else
    # 入力情報が空の場合
      flash[:notice] = "空欄の項目があります。すべて入力してください。"    
      render :hostNew
    end
  end
  
  
  
  
      private
        def pays_params
          
        end
        
        def register_bank_account
          @tenant = Tenant.find_by(user_id: current_user.id)
          unless @tenant.present?
            flash[:notice] = "銀行口座の登録を行ってください。"
            redirect_to user_pays_hostnew_path
          end
        end
        
        # 支払い情報の管理
        def pay_db_resister
          @pay = Pay.new(host_id: @event.user_id, price: @event.price, 
                         card_id: @card.id, reserve_id: @reserve.id, charge_id: @charge.id)
          @pay.user_id = current_user.id if user_signed_in?
          @pay.save
        end
        
        # カード情報の管理
        def card_db_resister
          @card = Card.new(customer_id: @customer.id, card_id: @customer.default_card)
          if @user.present?
            @card.user_id = current_user.id
          end
          @card.save
        end
        
        # payjpの支払いアクション
        def pay_action_createWithoutResistration
          begin 
            Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
            @customer = Payjp::Customer.create(
              card: params['payjp-token'],
              email: @reserve.email
            )
            card_db_resister
            @charge = Payjp::Charge.create(
              amount: @event.price.to_i,
              customer: @customer.id,
              currency: 'jpy',
              tenant: @tenant.tenant_id
            )
            pay_db_resister
            @reserve.update(payed: true)
            PayMailer.mail_pay_complite(@reserve).deliver_now
            render :createWithoutResistration
          
          rescue Payjp::CardError => e
            redirect_to pays_new_withoutresistration_path(reserve_id: @reserve.id)
            flash[:notice] = 'カード情報の取得ができませんでした。'
          rescue Payjp::InvalidRequestError => e
            redirect_to pays_new_withoutresistration_path(reserve_id: @reserve.id)
            flash[:notice] = '不正なパラメータが入力されました。'
          rescue Payjp::AuthenticationError => e
            redirect_to pays_new_withoutresistration_path(reserve_id: @reserve.id)
            flash[:notice] = 'カード情報の取得ができませんでした。'
          rescue Payjp::APIConnectionError => e
            redirect_to pays_new_withoutresistration_path(reserve_id: @reserve.id)
            flash[:notice] = '通信エラーが発生しました。もう一度登録をしてください。'
          rescue Payjp::APIError => e
            redirect_to pays_new_withoutresistration_path(reserve_id: @reserve.id)
            flash[:notice] = '通信エラーが発生しました。もう一度登録をしてください。'
          rescue Payjp::PayjpError => e
            redirect_to pays_new_withoutresistration_path(reserve_id: @reserve.id)
            flash[:notice] = 'カード情報の取得ができませんでした。'
          rescue StandardError
            redirect_to pays_new_withoutresistration_path(reserve_id: @reserve.id)
            flash[:notice] = 'エラーが発生しました。もう一度登録をしてください。'
          end
        end

        # payjpへテナント情報送信
        def payjp_create_tenant
          token = ENV["PAYJP_PRIVATE_KEY"]
          uri = URI.parse("https://api.pay.jp/v1/tenants")
          http = Net::HTTP.new(uri.host, uri.port)
          
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          req = Net::HTTP::Post.new(uri.path)
          req.basic_auth("#{token}", "")
          req.set_form_data({
            "name" => current_user.email,
            "minimum_transfer_amount" => "1000",
            "bank_account_holder_name" => params[:bank_account_holder_name],
            "bank_code" => params[:bank_code],
            "bank_branch_code" => params[:bank_branch_code],
            "bank_account_type" => params[:bank_account_type],
            "bank_account_number" => params[:bank_account_number],
            "platform_fee_rate" => "10",
            "payjp_fee_included" => true
          })
          res = http.request(req)
          data = JSON.parse(res.body)
          @tenant_id = data["id"]
        end
        
        # payjpからテナント情報取得
        def payjp_confirm_tenant
          @tenant = Tenant.find_by(user_id: current_user.id)
          if @tenant.present?
            token = ENV["PAYJP_PRIVATE_KEY"]
            uri = URI.parse("https://api.pay.jp/v1/tenants/#{@tenant.tenant_id}")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            
            req = Net::HTTP::Get.new(uri)
            req.basic_auth("#{token}", "")
            res = http.request(req)
            @data = JSON.parse(res.body)
          end
        end
        
        # payjpのテナント情報更新
        def payjp_update_tenant
          @tenant = Tenant.find_by(user_id: current_user.id)
          if @tenant.present?
            token = ENV["PAYJP_PRIVATE_KEY"]
            uri = URI.parse("https://api.pay.jp/v1/tenants/#{@tenant.tenant_id}")
            http = Net::HTTP.new(uri.host, uri.port)
            
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            req = Net::HTTP::Post.new(uri.path)
            req.basic_auth("#{token}", "")
            req.set_form_data({
              "name" => current_user.email,
              "bank_account_holder_name" => params[:bank_account_holder_name],
              "bank_code" => params[:bank_code],
              "bank_branch_code" => params[:bank_branch_code],
              "bank_account_type" => params[:bank_account_type],
              "bank_account_number" => params[:bank_account_number],
            })
            res = http.request(req)
            @data = JSON.parse(res.body)
          end
        end
        
        # 入金情報の取得
        def payjp_transfer_info
          @tenant = Tenant.find_by(user_id: current_user.id)
          if @tenant.present?
            token = ENV["PAYJP_PRIVATE_KEY"]
            uri = URI.parse("https://api.pay.jp/v1/tenant_transfers")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            
            req = Net::HTTP::Get.new(uri)
            req.basic_auth("#{token}", "")
            req.set_form_data({
              "tenant" => @tenant.tenant_id,
              "limit" => 100
            })
            res = http.request(req)
            
            puts res.body
            @data = JSON.parse(res.body)
          end
        end
        
        
        def credit_card_info
          if @card.present?
            Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
            @customer = Payjp::Customer.retrieve(@card.customer_id)
            @card_information = @customer.cards.retrieve(@card.card_id)
          end
        end
        
        def payjp_rescue
          begin 
          rescue Payjp::CardError => e
            flash.now[:notice] = 'カード情報の取得ができませんでした。'
            render :new
          rescue Payjp::InvalidRequestError => e
            flash.now[:notice] = '不正なパラメータが入力されました。'
            render :new
          rescue Payjp::AuthenticationError => e
            flash.now[:notice] = 'カード情報の取得ができませんでした。'
            render :new
          rescue Payjp::APIConnectionError => e
            flash.now[:notice] = '通信エラーが発生しました。もう一度登録をしてください。'
            render :new
          rescue Payjp::APIError => e
            flash.now[:notice] = '通信エラーが発生しました。もう一度登録をしてください。'
            render :new
          rescue Payjp::PayjpError => e
            flash.now[:notice] = 'カード情報の取得ができませんでした。'
            render :new
          rescue StandardError
            flash.now[:notice] = 'エラーが発生しました。もう一度登録してください。'
            render :new
          end
        end
end
