class TeachingAssistant < ApplicationRecord
  has_many :assignments, dependent: :nullify
  has_many :courses, through: :assignments

  validates :year, :number, :name, :grade, :labo, presence: true
  validates :year, numericality: { in: 2020..2100 }
  validates :number, format: { with: /\A[0-9A-Z]+\z/, message: "数字と英大文字のみが使えます" }
  validates :grade, inclusion: { in: %w(M1 M2 D1 D2 D3), message: "学年 %{value} は無効です" }
end
