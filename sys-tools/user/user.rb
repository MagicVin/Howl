#!/usr/bin/env ruby
class User
  attr_accessor :user
  def initialize(user = "")
    unless user.empty?
      @user = user
    else
      out "the program needs to know the user who is performing it"
      Process.exit -1
    end
  end

  def out(msg)
    puts "  #{msg}"
  end

  def s(str)
    return "\'#{str}\'"
  end
  
  def show
    out "user: #{@user}"
  end

  def bashrc
    user_settings = Hash.new
    user_settings = {
     "ll" => "ls -rtl" ,
    }

    user_conf = "/home/#{@user}/.bashrc" unless @user == "root"
    user_conf = "/#{@user}/.bashrc" if @user == "root"
    user_settings.each do |k,v| 
      text = File.read(user_conf)
      if text.include? "alias #{k}"
        new_contents = text.gsub(/alias #{k}.*$/,"alias #{k}=#{s(v)}")
        File.open(user_conf, 'w') { |file| file.puts new_contents }
      else
        File.open(user_conf, 'a') { |file| file.puts "alias #{k}=#{s(v)}"}
      end
    end
  end

  def vim
    vim_settings = Array.new
    vim_settings = %w(
      ts=2 
      expandtab 
      autoindent 
      relativenumber 
      cursorline 
      wrap 
      linebreak
    )
    vim_conf = "/home/#{@user}/.vimrc" unless @user == "root"
    vim_conf = "/#{@user}/.vimrc" if @user == "root"
    File.open(vim_conf, 'w') do |file|
      vim_settings.each { |v| file.puts "set #{v}" }
    end
  end

end


def main
  o = User.new("cloud")
  #o = User.new("root")
  o.show
  o.bashrc
  o.vim
end

main
