require "rubygems"
require "active_record"

# DB接続設定
ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "db/main.db",
    :pool => 5,
    :timeout => 5000,
)
