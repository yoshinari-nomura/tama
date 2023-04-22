class Assignment < ApplicationRecord
  has_many :work_hours, dependent: :destroy
  belongs_to :course
  belongs_to :teaching_assistant, optional: true

  validates :course, presence: true

  def teaching_assistant_name
    self.teaching_assistant || "unspecified-#{self.id}"
  end
end
