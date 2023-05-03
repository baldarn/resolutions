# frozen_string_literal: true

class Reminder < ApplicationRecord
  validates :body, presence: true

  belongs_to :resolution
end
