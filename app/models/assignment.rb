class Assignment < ApplicationRecord
  has_many :work_hours, dependent: :destroy
  validates :course, presence: true
  belongs_to :course
  belongs_to :teaching_assistant, optional: true
end
