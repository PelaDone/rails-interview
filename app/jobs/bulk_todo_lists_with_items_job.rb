class BulkTodoListsWithItemsJob < ApplicationJob
  queue_as :default

  def perform(todo_lists_with_items, callback_url = nil)
    result = BulkOperationsService.bulk_create_todo_lists_with_items(todo_lists_with_items)

    # Si se proporcionó una URL de callback, notificar el resultado
    notify_completion(callback_url, result) if callback_url.present?
    
    # Registrar el resultado en logs
    Rails.logger.info("BulkTodoListsWithItemsJob completed: #{result.to_json}")
    
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