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
require_relative 'model/state'

begin
    @cgi = CGI.new
    @session = CGI::Session.new(@cgi)

    if @session['id'].nil?
        print @cgi.header({'status' => '302 Found', 'Location' => "login.rb" })
        @session.close
        exit
    end

    @current_user = User.find(@session['id'].to_i)
    
    @current_project = Project.find_by(id: @cgi['id'].to_i)
    if @current_project.nil?
        print @cgi.header({'status' => '302 Found', 'Location' => "projects.rb" })
        @session.close
        exit
    end

    if @current_user != @current_project.user && !Member.where(user: @current_user).where(project: @current_project).exists?
        print @cgi.header({'status' => '302 Found', 'Location' => "projects.rb" })
        @session.close
        exit
    end

    @tasks = Task.eager_load(:user).eager_load(:state).where(project: @current_project)

    @members = Member.where(project: @current_project)

    if @cgi.params.include?("search")
        words = @cgi["word"].split(/\s/)
        words.each do |word|
            @tasks = @tasks.where("title like ? or detail like ? ", '%' + word + '%', '%' + word + '%')
            .or(@tasks.merge(User.where("users.name like ?", '%' + word + '%')))
            .or(@tasks.merge(State.where("states.name like ?", '%' + word + '%')))
        end
        if @cgi["finish"] != "on"
            @tasks = @tasks.merge(State.where.not(progress: 100))
        end
    else
        @tasks = @tasks.merge(State.where.not(progress: 100))
    end

    header = ERB.new(File.read("view/header.rhtml"))
    @header = header.result(binding)
    body = ERB.new(File.read("view/tasks.rhtml"))
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