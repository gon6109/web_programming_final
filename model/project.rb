require "active_record"
require_relative "../db/db"

class Project < ActiveRecord::Base
    has_many :members, dependent: :destroy
    has_many :states, dependent: :destroy
    belongs_to :user
end