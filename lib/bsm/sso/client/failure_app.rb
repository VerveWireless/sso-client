class Bsm::Sso::Client::FailureApp < ActionController::Metal
  include ActionController::RackDelegation
  include ActionController::Redirecting
  include ActionController::Rendering
  include Bsm::Sso::Client::UrlHelpers

  def self.call(env)
    action(:respond).call(env)
  end

  def self.default_url_options(*args)
    ApplicationController.default_url_options(*args)
  end

  def respond
    if Bsm::Sso::Client.navigational_formats.include?(request.format.try(:to_sym)) || request.accepts.include?(Mime::HTML)
      request.xhr? ? respond_with_js! : redirect!
    else
      stop!
    end
  end

  def redirect!
    path = env["warden.options"].try(:[], :attempted_path) || request.fullpath
    message = env["warden.options"][:message]
    if message.nil?
      redirect_to Bsm::Sso::Client.user_class.sso_sign_in_url(:service => service_url(path)), :status => 303
    else
      redirect_to Bsm::Sso::Client.user_class.sso_sign_out_url(:service => service_url(path))
    end
  end

  def respond_with_js!
    self.status = :ok
    self.content_type  = request.format.to_s
    path = env["warden.options"].try(:[], :attempted_path) || request.fullpath
    url = Bsm::Sso::Client.user_class.sso_sign_out_url(:service => service_url(path))
    self.response_body = "alert('Your session has expired'); location = '#{url}' "
  end

  def stop!
    render :text => "<html><head></head><body><h1>Access Forbidden</h1></body></html>", :status => 403, :content_type => Mime::HTML
  end

end
