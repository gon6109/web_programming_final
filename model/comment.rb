require "active_record"
require_relative "../db/db"

class Comment < ActiveRecord::Base
    belongs_to :task
    belongs_to :user
end