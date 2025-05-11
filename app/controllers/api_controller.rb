class ApiController < ActionController::API
  rescue_from ActionController::UnknownFormat, with: :raise_not_found

  def raise_not_found
    render json: { error: 'Not supported format' }, status: 406
  end
end