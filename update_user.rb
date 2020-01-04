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

def print_update_user_form(cgi, error=nil)
    if !error.nil?
        @error = error
    end 
    header = ERB.new(File.read("view/header.rhtml"))
    @header = header.result(binding)
    body = ERB.new(File.read("view/update_user.rhtml"))
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
    
    if cgi.params.include?("update")
        mailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        if !cgi["mail_address"].match? mailRegex
            print_update_user_form(cgi, "メールアドレスが正しくありません")
            @session.close
            exit
        end

        if User.where(mail_address: cgi["mail_address"]).where.not(id: @current_user.id).exists?
            print_update_user_form(cgi, "すでに登録されています")
            @session.close
            exit
        end

        if cgi["name"] == ""
            print_update_user_form(cgi, "名前を入力してください")
            @session.close
            exit
        end

        if cgi["password"] == "" || cgi["password"] != cgi["password_confirmation"]
            print_update_user_form(cgi, "パスワードが正しくありません")
            @session.close
            exit
        end

        @current_user.mail_address = cgi["mail_address"]
        @current_user.name = cgi["name"]
        @current_user.hashed_password = BCrypt::Password.create(cgi["password"])
        
        if !@current_user.save
            print_update_user_form(cgi, "データベースに保存できませんでした")
            @session.close
            exit
        end

        print cgi.header({'status' => '302 Found', 'Location' => "projects.rb" })
        @session.close
        exit
    end

    print_update_user_form(cgi)
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