class BulkTodoListsJob < ApplicationJob
  queue_as :default

  def perform(operation, todo_lists_attributes, callback_url = nil)
    case operation.to_sym
    when :create
      result = BulkOperationsService.bulk_create_todo_lists(todo_lists_attributes)
    when :update
      result = BulkOperationsService.bulk_update_todo_lists(todo_lists_attributes)
    else
      result = { success: false, error: "Unknown operation: #{operation}" }
    end

    # Si se proporcionó una URL de callback, notificar el resultado
    notify_completion(callback_url, result) if callback_url.present?
    
    # Registrar el resultado en logs
    Rails.logger.info("BulkTodoListsJob #{operation} completed: #{result.to_json}")
    
    result
  end
  
  private
  
  def notify_completion(callback_url, result)
    # Realizar una petición HTTP POST al callback_url con el resultado
    require 'net/http'
    require 'uri'
    
    begin
      uri = URI.parse(callback_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      
      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = result.to_json
      
      response = http.request(request)
      Rails.logger.info("Callback notification sent to #{callback_url}, response: #{response.code}")
    rescue => e
      Rails.logger.error("Failed to send callback notification: #{e.message}")
    end
  end
end