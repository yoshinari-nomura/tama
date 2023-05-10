class Assignment < ApplicationRecord
  has_many :work_hours, dependent: :destroy
  belongs_to :course
  belongs_to :teaching_assistant, optional: true

  validates :course, presence: true
  validates :teaching_assistant, uniqueness: { scope: :course, message: "科目に同一のTAが既にいます"}

  def teaching_assistant_name
    return "TA-#{self.id}" unless self.teaching_assistant
    self.teaching_assistant.name
  end
end
