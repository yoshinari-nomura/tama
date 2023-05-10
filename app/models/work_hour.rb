class WorkHour < ApplicationRecord
  belongs_to :assignment
  has_one :course, through: :assignment

  validates :dtstart, presence: true
  validates :dtend, :actual_working_minutes, presence: { message: '' }
  validates :dtend, comparison: { greater_than: :dtstart, message: "は開始時刻後にして下さい" }
  validates :actual_working_minutes, numericality: { in: 1..600  }
end
