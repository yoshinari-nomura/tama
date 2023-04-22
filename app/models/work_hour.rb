class WorkHour < ApplicationRecord
  validates :assignment, presence: true
  validates :actual_working_minutes, numericality: { in: 1..600  }
  validates :dtend, comparison: { greater_than: :dtstart }
  belongs_to :assignment
end
