require "active_record"
require_relative "../db/db"

class User < ActiveRecord::Base
    has_many :projects, dependent: :destroy
    has_many :tasks, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :members, dependent: :destroy
end