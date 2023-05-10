#!/bin/bash

set -eu

# Create the first scaffolding models according to doc/ta-system.org

rails=./bin/rails

# Course
#
$rails g scaffold \
  course \
    year:integer \
    term:string \
    number:string \
    name:string \
    instructor:string \
    time_budget:integer \
    description:string \
    --force

# TeachingAssistant
#
$rails g scaffold \
  teaching_assistant \
    year:integer \
    number:string \
    name:string \
    grade:string \
    labo:string \
    description:string \
    --force

# Assignment
#
$rails g scaffold \
  assignment \
    course:references \
    teaching_assistant:references \
    description:string \
    --force

# teaching_assistant column of Assignment should be nullable, but
# rails generator can't create nullable type. So replace it.
#
# db/migrate/*_create_assignments.rb:
#    t.references :teaching_assistant, null: false, foreign_key: true
#    → t.references :teaching_assistant, null: true, foreign_key: true
#
sed --in-place '/:teaching_assistant/s/null: false/null: true/' \
  db/migrate/*_create_assignments.rb

# Assignment belongs_to :teaching_assistant, optional: true
# (allow special state that TA is not fixed yet)
#
# app/models/assignment.rb:
#   belongs_to :teaching_assistant
#   → belongs_to :teaching_assistant, optional: true
#
sed --in-place '/belongs_to :teaching_assistant/s/$/, optional: true/' \
  app/models/assignment.rb

# WorkHour
#
$rails g scaffold \
  WorkHour \
    dtstart:datetime \
    dtend:datetime \
    actual_working_minutes:integer \
    assignment:references \
    --force

################################################################
# Add validations and associations for each model.
#
function add() {
  local model="$1" relation="$2"
  local file="app/models/$model".rb

  sed --in-place "/^end$/i \ \ $relation" "$file"
}

################
# course

add course 'has_many :assignments, dependent: :destroy'
add course 'has_many :teaching_assistants, through: :assignments'
ass course 'has_many :work_hours, through: :assignments'
add course ''
add course 'validates :year, :term, :number, :name, :instructor, :time_budget, presence: true'
add course 'validates :year, numericality: { in: 2020..2100 }'
add course 'validates :time_budget, numericality: { in: 0..1000000 }'

################
# teaching_assistant

add teaching_assistant 'has_many :assignments, dependent: :nullify'
add teaching_assistant 'has_many :courses, through: :assignments'
add teaching_assistant ''
add teaching_assistant 'validates :year, :number, :name, :grade, :labo, presence: true'
add teaching_assistant 'validates :year, numericality: { in: 2020..2100 }'
add teaching_assistant 'validates :number, format: { with: /\A[0-9A-Z]+\z/, message: "には数字と英大文字のみが使えます" }'
add teaching_assistant 'validates :grade, inclusion: { in: %w(M1 M2 D1 D2 D3), message: "の %{value} は無効です" }'

################
# assignment

add assignment 'has_many :work_hours, dependent: :destroy'
add assignment ''
add assignment 'validates :course, presence: true'
add assignment 'validates :teaching_assistant, uniqueness: { scope: :course, message: "科目に同一のTAが既にいます"}'

################
# work_hour

add work_hour 'has_one :course, through: :assignment'
add work_hour ''

add work_hour 'validates :dtstart, presence: true'
add work_hour 'validates :dtend, :actual_working_minutes, presence: { message: '' }'
add work_hour 'validates :dtend, comparison: { greater_than: :dtstart, message: "は開始時刻後にして下さい" }'
add work_hour 'validates :actual_working_minutes, numericality: { in: 1..600  }'

################################################################
# do migration

read -p "Do you also want to db:migrate ? (yes/NO): " yesno

if [ "$yesno" != "yes" ]; then
  echo "OK, please do $rails db:migrate by yourself."
  exit 0
fi

echo "Doing $rails db:migrate..."
$rails db:migrate

################################################################
# Import data from doc/ta-system.org

read -p "Do you also want to import initial data from doc/ta-system.org ? (yes/NO): " yesno

if [ "$yesno" != "yes" ]; then
  echo "OK, please do $rails runner scripts/import-data-from-csv-or-org.rb doc/ta-system.org by yourself"
  exit 0
fi

echo "Doing $rails runner scripts/import-model.rb doc/ta-system.org..."
$rails runner scripts/import-model.rb doc/ta-system.org
