#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'erb'
require 'bcrypt'
require 'cgi/session'

require_relative 'model/user'

def print_login_form(cgi, error=nil)
    if !error.nil?
        @error = error
    end
    header = ERB.new(File.read("view/header.rhtml"))
    @header = header.result(binding)
    body = ERB.new(File.read("view/login.rhtml"))
    @body = body.result(binding)

    layout = ERB.new(File.read("view/layout.rhtml"))
    print cgi.header("text/html; charset=utf-8")
    print layout.result(binding)
end

begin
    cgi = CGI.new
    @session = CGI::Session.new(cgi)
    @session.delete
    @session = CGI::Session.new(cgi)

    if cgi.params.include?("login")
        user = User.find_by(mail_address: cgi["mail_address"])
        
        if user.nil?
            print_login_form(cgi, "ユーザ名が正しくありません")
            @session.close
            exit
        end

        password = BCrypt::Password.new(user.hashed_password)
        if password != cgi["password"]
            print_login_form(cgi, "パスワードが正しくありません")
            @session.close
            exit
        end

        @session['id'] = user.id

        print cgi.header({'status' => '302 Found', 'Location' => "menu.rb" })
        @session.close
        exit
    end

    print_login_form(cgi)
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