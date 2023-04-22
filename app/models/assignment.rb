class Assignment < ApplicationRecord
  has_many :work_hours, dependent: :destroy
  validates :course, presence: true
  belongs_to :course
  belongs_to :teaching_assistant, optional: true

  def teaching_assistant_name
    self.teaching_assistant || "unspecified-#{self.id}"
  end
end
