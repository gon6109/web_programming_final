#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'erb'
cgi = CGI.new
body = ERB.new(File.read("view/index.rhtml"))
@body = body.result(binding)

layout = ERB.new(File.read("view/layout.rhtml"))
print cgi.header("text/html; charset=utf-8")
print layout.result(binding)