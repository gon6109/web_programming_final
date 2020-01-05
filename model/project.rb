require "active_record"
require_relative "../db/db"

require_relative "task"
require_relative "state"

class Project < ActiveRecord::Base
    has_many :members, dependent: :destroy
    has_many :states, dependent: :destroy
    has_many :tasks, dependent: :destroy
    belongs_to :user

    def task_count
        self.tasks.count
    end

    def not_finish_task_count
        self.tasks.eager_load(:state).merge(State.where.not(progress: 100)).count
    end

    def task_progress_average
        self.tasks.eager_load(:state).average(:progress)
    end

end