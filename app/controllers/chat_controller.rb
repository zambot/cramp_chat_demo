class ChatController < WebSocketApplicationController
  on_data :receive_message
  on_start :retrieve_messages

  on_new_data :new_data

  def new_data(msg)
    list = [{ "from" => msg.name, "msg" => msg.message, "sent" => msg.sent_at.to_formatted_s(:short) }]
    render list.to_json
  end
  
  def retrieve_messages
    @last_message ||= (Time.now - 10.hours)
    Chat.recent(@last_message).all do |messages|
      list = messages.map { |msg| { "from" => msg.name, "msg" => msg.message, "sent" => msg.sent_at.to_formatted_s(:short) } }
      if list.size > 0
        @last_message = messages.last.try(:sent_at) || @last_message
        render list.to_json
      end
    end
  end

  def receive_message(data)
    params = Rack::Utils.parse_query(data)

    chat = Chat.new :name => params["from"],
      :sent_at => Time.now,
      :message => params["msg"]

    chat.save do |status|
      if status.success?
        render formatted_msg("Message Successfully Received.")
      else
        render formatted_msg("Error receiving message: #{status.inspect}.")
      end
    end
  end
end
