require "active_record"
require_relative "../db/db"

class Member < ActiveRecord::Base
    belongs_to :user
    belongs_to :project
end