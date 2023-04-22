#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

VERSION = "0.1.0"

def usage
  STDERR.puts "Usage: bin/rails runner scripts/import-model.rb TECHNICAL-NOTE.org"
  STDERR.puts "       bin/rails runner scripts/import-model.rb --table-type=csv --table-name={MODEL} file.csv"
  STDERR.puts "Example:"
  STDERR.puts "  bin/rails runner scripts/import-model.rb --table-type=csv --table-name=courses courses.csv"
end

unless "my_model".respond_to?(:classify)
  usage
  exit 1
end

# Parse CSV or Org-mode table and create Rails model from each row.
#
# org-mode: https://orgmode.org/
#
class TableParser
  # Parse CSV or Org-mode table and create Rails model from each row.
  #
  # Parameters:
  #   source_string: CSV or org-mode table as single string.
  #   model: ActiveRecord model class corresponds to source_string.
  #   type: one of :org or :csv
  #
  # Example:
  #   # courese.csv has column names in the first row.
  #   # column names will be normalized by normalize_column_name method.
  #   TableParser.parse(File.read("courses.csv", Course, :csv))
  #
  def self.parse(source_string, model, type = :org)
    concrete_parser =
      case type
      when :org
        ORG.new(source_string)
      when :csv
        CSV.new(source_string)
      else
        raise "Unknown table type #{type}."
      end

    count = 0
    concrete_parser.each_row do |row|
      count += 1
      p row
      model.create!(row)
    end
    return count
  end

  class Base
    attr_reader :source_string

    def initialize(source_string)
      @source_string = source_string
    end

    def normalize_column_name(column_name)
      if column_name =~ /\(([a-zA-Z0-9_]+)\)\s*$/
        $1
      else
        column_name
      end
    end
  end

  class CSV < Base
    require "csv"

    def each_row(&block)
      lines = begin
                # try to conver Shift_JIS into UTF-8
                source_string.encode("UTF-8", "Shift_JIS")
              rescue
                source_string.encode("UTF-8", "UTF-8")
              end

      colnames = []
      ::CSV.parse(lines, :headers => false) do |cols|
        if colnames.empty?
          # take the first line as column names.
          colnames = cols.map {|c| normalize_column_name(c) }
        else
          yield Hash[colnames.zip cols]
        end
      end
    end
  end

  class ORG < Base
    def each_row(&block)
      colnames = []
      lines = source_string.force_encoding("UTF-8").split("\n")

      lines.each do |line|
        next if line =~ /^\s*\|-/    # skip horizontal line |--
        next unless line =~ /^\s*\|/ # skip non-table line

        cols = line.sub(/^\s*\|/, '').sub(/\|\s*$/, '').split('|').map(&:strip)

        if colnames.empty?
          # take the first line as column names.
          colnames = cols.map {|c| normalize_column_name(c) }
        else
          yield Hash[colnames.zip cols]
        end
      end
    end
  end
end

def extract_tables_from_org(source_string, &block)
  lines = source_string.split("\n")
  table_name, table_content = nil, []

  lines.each do |line|
    # On the new headline:
    #   make sure to cancel table_name from the previous section.
    #   flush table_content to caller if is has.
    if line =~ /^\*+\s+/
      if table_name && !table_content.empty?
        yield(table_name, table_content.join("\n"))
      end
      table_name, table_content = nil, []
    end

    # Take new table_name from headline:
    # ** table: courses (description: .....)
    # → courses
    table_name = $1 if line =~ /^\*+\s+table:\s*([a-zA-Z0-9_]+)\s*/i

    # if line is the part of a table, add to table_content
    table_content << line if line =~ /^\s*\|/
  end

  if table_name && !table_content.empty?
    yield(table_name, table_content.join("\n"))
  end
end

################################################################
## main
################################################################

$OPT_TABLE_TYPE = :org
$DEBUG_FLAG     = false

while /^-/ =~ ARGV[0]
  case ARGV[0]
  when /^--debug/
    $DEBUG_FLAG = true
  when /^--table-type=(org|csv)$/
    $OPT_TABLE_TYPE = $1.to_sym
  when /^--table-name=(.*)$/
    $OPT_TABLE_NAME = $1.strip
  when /^--version/
    puts VERSION
    exit 0
  else
    usage()
    exit 1
  end
  ARGV.shift
end

if ARGV[0].nil? || ($OPT_TABLE_TYPE == :csv && $OPT_TABLE_NAME.to_s.empty?)
  usage
  exit 1
end

count = 0

case $OPT_TABLE_TYPE
when :org
  extract_tables_from_org(gets(nil)) do |table_name, source_string|
    puts "table_name: #{table_name}"
    model = table_name.classify.constantize
    count = TableParser.parse(source_string, model, :org)
    puts "Added #{count} object(s) to #{model.name}."
  end
when :csv
  model = $OPT_TABLE_NAME.classify.constantize
  count = TableParser.parse(gets(nil), model, :csv)
  puts "Added #{count} object(s) to #{model.name}."

else
  STDERR.puts "Unknown table type: #{$OPT_TABLE_TYPE}."
  exit 1
end

exit 0
