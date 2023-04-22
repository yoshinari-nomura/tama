class Course < ApplicationRecord
  has_many :assignments, dependent: :destroy
  has_many :teaching_assistants, through: :assignments
  validates :time_budget, numericality: { in: 0..1000000 }
  validates :year, numericality: { in: 2020..2100 }
  validates :term, :number, :name, :instructor, presence: true
end
