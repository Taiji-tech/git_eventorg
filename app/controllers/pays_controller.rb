class PaysController < ApplicationController
  
  # http通信実装のためのライブラリ
  require 'net/http'
  require 'uri'
  require 'payjp'
  
  # カード情報の登録
  def new
    @card = Card.find_by(user_id: current_user.id)
  end
  
  # ユーザーからイベントホストへの支払い作成
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
        puts @customer
        @card = Card.new(user_id: current_user.id, customer_id: @customer.id, card_id: @customer.default_card)
        @card.save
        
        redirect_to user_pays_confirm_card_path
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
        @customer = Payjp::Customer.create(
          card: params['payjp-token']
        )
        puts @customer
        @card = Card.new(user_id: current_user.id, customer_id: @customer.id, card_id: @customer.default_card)
        @card.save
        
        redirect_to user_pays_confirm_card_path
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
  
  # 支払い情報の確認
  def confirm
    
  end  

  
  
  
  # イベントホストのカード情報入力
  def hostNew
    @tenant = Tenant.where(user_id: current_user.id)
  end
  
  # イベントホストのカード情報登録
  def hostCreate
    if params[:bank_code].present? && params[:bank_branch_code].present? && params[:bank_account_type].present? &&
       params[:bank_account_number].present? && params[:bank_account_holder_name].present?  
      # begin
        # payjp通信
        payjp_create_tenant
        
        # @tenant = Tenant.new(user_id: current_user.id, tenant_id: response.id) 
        # @tenant.save
        

      # rescue 
      #   flash[:notice] = "入力いただいた情報に不備があります。再度入力してください"    
      #   render :hostNew
      # end
    else
    # 入力情報が空の場合
      flash[:notice] = "空欄の項目があります。すべて入力してください。"    
      render :hostNew
    end
  end
  
  # ホストが登録しているカード情報確認
  def hostInfo
    
  end
  
  
      private
        def pays_params
          
        end
        
        def payjp_create_tenant
          uri = URI.parse("https://api.pay.jp/v1/tenants")
          request = Net::HTTP::Post.new(uri)
          request.basic_auth("sk_test_c07de1779f5523390287df4d", "")
          request.set_form_data(
            "bank_account_holder_name" => params[:bank_account_holder_name],
            "bank_account_number" => params[:bank_account_number],
            "bank_account_type" => params[:bank_account_type],
            "bank_branch_code" => params[:bank_branch_code],
            "bank_code" => params[:bank_code],
            "id" => "test",
            "minimum_transfer_amount" => "1000",
            "name" => "test",
            "platform_fee_rate" => "10",
          )
          
          req_options = {
            use_ssl: uri.scheme == "https",
          }
          
          response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            res = http.request(request)
          end
          puts response.id
        end
        
        def credit_card_info
          if @card.present?
            Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
            @customer = Payjp::Customer.retrieve(@card.customer_id)
            @card_information = @customer.cards.retrieve(@card.card_id)
          end
        end
        
        def payjp_confirm_tenant
          
        
        end
end
