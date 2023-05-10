class Course < ApplicationRecord
  has_many :assignments, dependent: :destroy
  has_many :teaching_assistants, through: :assignments
  has_many :work_hours, through: :assignments

  validates :year, :term, :number, :name, :instructor, :time_budget, presence: true
  validates :year, numericality: { in: 2020..2100 }
  validates :time_budget, numericality: { in: 0..1000000 }
end
