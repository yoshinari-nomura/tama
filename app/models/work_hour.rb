class WorkHour < ApplicationRecord
  belongs_to :assignment
  has_one :course, through: :assignment

  validates :dtstart, presence: true
  validates :dtend, :actual_working_minutes, presence: { message: '' }
  validates :dtend, comparison: { greater_than: :dtstart, message: "は開始時刻後にして下さい" }
  validates :actual_working_minutes, numericality: { in: 1..600  }

  def date
    dtstart.to_date
  end

  def date=(date)
    y, m, d, s, e = date.year, date.month, date.day, dtstart, dtend
    self.dtend   = Time.new(y, m, d, e.hour, e.min, e.sec)
    self.dtstart = Time.new(y, m, d, s.hour, s.min, s.sec)
    self
  end

  def slide(days)
    self.date += days
    self
  end

  def colleagues
    course = Course.find(self.course.id)
    course.work_hours.where(
      dtstart: self.dtstart,
      dtend: self.dtend,
      actual_working_minutes: self.actual_working_minutes
    )
  end
end
