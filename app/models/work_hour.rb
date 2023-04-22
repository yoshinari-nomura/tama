class WorkHour < ApplicationRecord
  belongs_to :assignment

  validates :assignment, presence: true
  validates :dtend, comparison: { greater_than: :dtstart }
  validates :actual_working_minutes, numericality: { in: 1..600  }
end
