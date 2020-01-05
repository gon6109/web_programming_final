require "active_record"
require_relative "../db/db"

class Task < ActiveRecord::Base
    belongs_to :project
    belongs_to :user
    belongs_to :state
    has_many :comments, dependent: :destroy
end