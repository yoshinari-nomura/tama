class Course < ApplicationRecord
  has_many :assignments, dependent: :destroy
  has_many :teaching_assistants, through: :assignments
  has_many :work_hours, through: :assignments

  validates :year, :term, :number, :name, :instructor, :time_budget, presence: true
  validates :year, numericality: { in: 2020..2100 }
  validates :time_budget, numericality: { in: 0..1000000 }

  def work_hours_calendar
    calendar = {}
    work_hours = self.work_hours.order(:dtstart)
    work_hours = work_hours.group_by {|w| [w.dtstart, w.dtend, w.actual_working_minutes] }

    work_hours.each do |time_slot, work_hours|
      date = time_slot[0].to_date
      calendar[date] ||= {}
      calendar[date][time_slot] = work_hours
    end
    return calendar
  end
end
