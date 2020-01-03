#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'erb'
require 'bcrypt'
require 'cgi/session'

require_relative 'model/user'

def print_register_form(cgi, error=nil)
    if !error.nil?
        @error = error
    end 
    header = ERB.new(File.read("view/header.rhtml"))
    @header = header.result(binding)
    body = ERB.new(File.read("view/register_user.rhtml"))
    @body = body.result(binding)

    layout = ERB.new(File.read("view/layout.rhtml"))
    print cgi.header("text/html; charset=utf-8")
    print layout.result(binding)
end

begin
    cgi = CGI.new

    if cgi.params.include?("register")
        mailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        if !cgi["mail_address"].match? mailRegex
            print_register_form(cgi, "メールアドレスが正しくありません")
            exit
        end

        if User.where(mail_address: cgi["mail_address"]).exists?
            print_register_form(cgi, "すでに登録されています")
            exit
        end

        if cgi["name"] == ""
            print_register_form(cgi, "名前を入力してください")
            exit
        end

        if cgi["password"] == "" || cgi["password"] != cgi["password_confirmation"]
            print_register_form(cgi, "パスワードが正しくありません")
            exit
        end

        user = User.new
        user.mail_address = cgi["mail_address"]
        user.name = cgi["name"]
        user.hashed_password = BCrypt::Password.create(cgi["password"])
        
        if !user.save
            print_register_form(cgi, "データベースに保存できませんでした")
            exit
        end

        @session = CGI::Session.new(cgi)
        @session['id'] = user.id

        print cgi.header({'status' => '302 Found', 'Location' => "menu.rb" })
        exit
    end

    print_register_form(cgi)

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