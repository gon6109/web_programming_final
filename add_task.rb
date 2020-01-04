#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'erb'
require 'bcrypt'
require 'cgi/session'

require_relative 'model/user'
require_relative 'model/project'
require_relative 'model/task'
require_relative 'model/member'

def print_add_task_form(cgi, error=nil)
    if !error.nil?
        @error = error
    end 
    header = ERB.new(File.read("view/header.rhtml"))
    @header = header.result(binding)
    body = ERB.new(File.read("view/add_task.rhtml"))
    @body = body.result(binding)

    layout = ERB.new(File.read("view/layout.rhtml"))
    print cgi.header("text/html; charset=utf-8")
    print layout.result(binding)
end

begin
    cgi = CGI.new
    @session = CGI::Session.new(cgi)

    if @session['id'].nil?
        print cgi.header({'status' => '302 Found', 'Location' => "login.rb" })
        @session.close
        exit
    end

    @current_user = User.find(@session['id'].to_i)
    
    @current_project = Project.find_by(id: cgi['id'].to_i)
    if @current_project.nil?
        print cgi.header({'status' => '302 Found', 'Location' => "projects.rb" })
        @session.close
        exit
    end

    if @current_user != @current_project.user && !Member.where(user: @current_user).where(project: @current_project).exists?
        print cgi.header({'status' => '302 Found', 'Location' => "projects.rb" })
        @session.close
        exit
    end

    @users = User.eager_load(:members)
    @users = @users.where(id: @current_project.user.id).or(@users.where(members: { project: @current_project }))

    if cgi.params.include?("add")

        if cgi["title"] == ""
            print_add_task_form(cgi, "タスク名を入力してください")
            @session.close
            exit
        end

        task = Task.new
        task.project = @current_project
        task.title = cgi["title"]
        task.deadline = cgi["deadline"]
        task.user = User.find_by(id:cgi["user_id"].to_i)
        task.detail = cgi["detail"]
        
        if !task.save
            print_add_task_form(cgi, "データベースに保存できませんでした")
            @session.close
            exit
        end

        print cgi.header({'status' => '302 Found', 'Location' => "tasks.rb?id=" +  @current_project.id.to_s })
        @session.close
        exit
    end

    print_add_task_form(cgi)
    @session.close

rescue => e
    print cgi.header("text/html;charset=utf-8")
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