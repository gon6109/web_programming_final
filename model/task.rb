require "active_record"
require_relative "../db/db"

class Task < ActiveRecord::Base
    belongs_to :project
    belongs_to :user
end