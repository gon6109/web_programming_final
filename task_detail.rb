#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'erb'
require 'bcrypt'
require 'cgi/session'

require_relative 'model/user'
require_relative 'model/project'
require_relative 'model/task'
require_relative 'model/comment'

begin
    @cgi = CGI.new
    @session = CGI::Session.new(@cgi)

    if @session['id'].nil?
        print @cgi.header({'status' => '302 Found', 'Location' => "login.rb" })
        @session.close
        exit
    end

    @current_user = User.find(@session['id'].to_i)
    
    @task = Task.find_by(id: @cgi['id'].to_i)
    if @task.nil?
        print @cgi.header({'status' => '302 Found', 'Location' => "projects.rb" })
        @session.close
        exit
    end

    if @current_user != @task.project.user
        print @cgi.header({'status' => '302 Found', 'Location' => "tasks.rb?id=" + @task.project.id.to_s })
        @session.close
        exit
    end

    @comments = Comment.where(task: @task)

    header = ERB.new(File.read("view/header.rhtml"))
    @header = header.result(binding)
    body = ERB.new(File.read("view/task_detail.rhtml"))
    @body = body.result(binding)

    layout = ERB.new(File.read("view/layout.rhtml"))
    print @cgi.header("text/html; charset=utf-8")
    print layout.result(binding)

    @session.close

rescue => e
    print @cgi.header("text/html;charset=utf-8")
    print <<EOF
<html>
    <head>
        <title>進捗ありますか？</title>
    </head>
    <body>
        <h1>500 Internal Sever Error</h1>
        <h2>#{e.message}</h2>
        #{CGI.escapeHTML(e.backtrace.join("\n"))}
    </body>
</html>
EOF
end