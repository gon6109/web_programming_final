require "active_record"
require_relative "../db/db"

class Project < ActiveRecord::Base
    belongs_to :user
end