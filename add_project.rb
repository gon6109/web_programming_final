#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'erb'
require 'bcrypt'
require 'cgi/session'

require_relative 'model/user'
require_relative 'model/project'

def print_add_project_form(cgi, error=nil)
    if !error.nil?
        @error = error
    end 
    header = ERB.new(File.read("view/header.rhtml"))
    @header = header.result(binding)
    body = ERB.new(File.read("view/add_project.rhtml"))
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

    if cgi.params.include?("add")

        if cgi["name"] == ""
            print_add_project_form(cgi, "プロジェクト名を入力してください")
            @session.close
            exit
        end

        project = Project.new
        project.name = cgi["name"]
        project.user = @current_user
        project.detail = cgi["detail"]
        
        if !project.save
            print_add_project_form(cgi, "データベースに保存できませんでした")
            @session.close
            exit
        end

        print cgi.header({'status' => '302 Found', 'Location' => "tasks.rb?id=" + project.id.to_s })
        @session.close
        exit
    end

    print_add_project_form(cgi)
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