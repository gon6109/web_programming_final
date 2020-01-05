require "active_record"
require_relative "../db/db"

class State < ActiveRecord::Base
    belongs_to :project
    has_many :tasks, dependent: :nullify
end