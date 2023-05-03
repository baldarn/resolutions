# frozen_string_literal: true

class Resolution < ApplicationRecord
  validates :body, presence: true
  validates :commitment, presence: true
  validates :time_limit, presence: true
  validates :temper, presence: true
  validates :offer, allow_blank: true, numericality: { only_numeric: true, greater_than_or_equal_to: 0 }

  enum :commitment, %i[low moderate high], prefix: true
  enum :temper, %i[motivational sarcastic authoritarian random], prefix: true

  belongs_to :user
  has_many :reminders, dependent: :destroy

  def reminder
    client = OpenAI::Client.new

    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{
          role: 'user',
          content: "
          write a #{temper_for_request} sentence to motivate me using at most 80 words in #{user.language} for my proposition.
          The proposition is delimited with triple backticks ```#{body}```
          "
        }]
      }
    )
    ai_generated_text = response.dig('choices', 0, 'message', 'content').gsub('```', '')
    reminders << Reminder.create(body: ai_generated_text)
  end

  def temper_for_request
    return Resolution.tempers.excluding('random').keys.sample if temper_random?

    temper
  end
end
