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

def print_update_project_form(cgi, error=nil)
    if !error.nil?
        @error = error
    end 
    header = ERB.new(File.read("view/header.rhtml"))
    @header = header.result(binding)
    body = ERB.new(File.read("view/update_project.rhtml"))
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
    
    @project = Project.find_by(id: cgi['id'].to_i)
    if @project.nil?
        print cgi.header({'status' => '302 Found', 'Location' => "projects.rb" })
        @session.close
        exit
    end

    @members = Member.where(project: @project)

    @states = State.where(project: @project)

    if @current_user != @project.user
        print cgi.header({'status' => '302 Found', 'Location' => "tasks.rb?id=" + @task.project.id.to_s })
        @session.close
        exit
    end

    @users = User.where.not(id: @current_user.id)

    if cgi.params.include?("update")

        if cgi["name"] == ""
            print_update_project_form(cgi, "プロジェクト名を入力してください")
            @session.close
            exit
        end

        @project.name = cgi["name"]
        @project.detail = cgi["detail"]

        before_member = Member.where(project: @project)
        
        cgi.params.select{ |k, v| k.include?("user_id")}.map{ |k, v| v[0]}.each do |item|
            next if item == "0"
            temp = Member.find_by(project: @project, user: User.find(item.to_i))
            if !temp.nil?
                before_member = before_member.where.not(id: temp.id)
                next
            end
            member = Member.new
            member.project = @project
            member.user = User.find(item.to_i)
            if !member.save
                print_add_project_form(cgi, "データベースに保存できませんでした")
                @session.close
                exit
            end
            before_member = before_member.where.not(id: member.id)
        end

        before_member.destroy_all

        before_state = State.where(project: @project)
        cgi.params.select{ |k, v| k.include?("state_name")}.map{ |k, v| [v[0], cgi["state_progress" + k.gsub(/state_name/, "")]]}.each do |name, progress|
            next if name == ""
            temp = State.find_by(name: name, project: @project)
            if !temp.nil?
                temp.progress = progress.to_i
                if !temp.save
                    print_add_project_form(cgi, "データベースに保存できませんでした")
                    @session.close
                    exit
                end
                before_state = before_state.where.not(id: temp.id)
                next
            end
            state = State.new
            state.name = name
            state.progress = progress.to_i
            state.project = @project
            if !state.save
                print_add_project_form(cgi, "データベースに保存できませんでした")
                @session.close
                exit
            end
            before_state = before_state.where.not(id: state.id)
        end

        before_state.destroy_all
        
        if !@project.save
            print_add_project_form(cgi, "データベースに保存できませんでした")
            @session.close
            exit
        end

        print cgi.header({'status' => '302 Found', 'Location' => "tasks.rb?id=" +  @project.id.to_s })
        @session.close
        exit
    end

    print_update_project_form(cgi)
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