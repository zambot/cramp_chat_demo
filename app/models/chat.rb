class Chat < Tramp::Base
  attribute :id, :type => Integer, :primary_key => true
  attribute :name
  attribute :sent_at
  attribute :message

  after_save :push_data
  
  def sent_at
    Time.parse(read_attribute(:sent_at))
  end
  
  def sent_at=(value)
    write_attribute(:sent_at, value.to_formatted_s(:db))
  end
  
  def self.recent(last_message)
    where(Chat[:sent_at].gt(last_message.to_formatted_s(:db))).
      order(Chat[:sent_at].asc)
  end

  def push_data
    ChatController.push_new_data(self)
  end
  
  validates_presence_of :name
end
