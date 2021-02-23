#!/usr/bin/env ruby
require 'time'

class FPS
  attr_accessor :app
  attr_accessor :fps_arr
  attr_accessor :instance
  attr_accessor :sum
  attr_reader :log

  def initialize(app = "") 
    Process.exit -1 if app.empty? 
    apps = Array.new
    apps = %w(com.tencent.tmgp.sgame)
    @app = app if apps.include? app
    @sum = Array.new()
    @fps_arr = Array.new()
    @log = "./totalfps.txt"
  end

  def show
    puts "app: #{@app}"
  end

  def instance_check(instance = "")
    Process.exit -1 if instance.empty? 
    IO.popen("docker inspect #{instance}") do |io|
      while line = io.gets
        if /Status/ =~ line
          status = line.gsub(/[',', ':', "\""]/," ").split()[-1]
          return status
        end
      end
    end
  end

  def pid(instance = "")
    Process.exit -1 if instance.empty? 
    IO.popen("docker exec #{instance} sh -c 'ps -ef | grep #{@app}'") do |io|
      while line = io.gets 
        if line.split()[7] =~ /^#{@app}$/
          return line.split()[1]
        end
      end
    end
    return -1
  end

  def log_fps(aplog = "", pid = "", length = 0)
    fps_text = Array.new
    fps_arr = Array.new
    if File.readable_real?(aplog) && ! pid.empty? && length > 0
      IO.popen("grep fps #{aplog}") do |io|
        while line = io.gets
          if line.split()[2] == pid && line.split()[9] == "fps"
            fps_text << line
          end
        end
      end

      if fps_text.empty?
        return %w(0) * 9
      end
      
      (fps_text.size - length.to_i).times { fps_text.shift if fps_text.size > length }
      #["01-05", "09:15:16.329", "733", "966", "E", "libEGL", ":", "EGLSurface", "0xb5d6fff0", "fps", "=", "30.71"]
      #    0         1             2      3     4       5      6         7             8         9     10     11
      File.open(@log, 'a') do |io|
        fps_text.each do |t|
          io.puts t
        end

      end

      head = Array.new
      tail = Array.new(11,0)

      if fps_text.size > 1
        head = fps_text[0].split()
        tail = fps_text[-1].split()
      else
        head = fps_text[0].split()
      end
      
      if alive?(head,tail).is_a?(Array) && ! alive?(head,tail).empty?
        fps_arr = (alive?(head,tail) | fps_arr)
      end
      
      fps_sum = 0.0
      fps_avg = 0.0
      fps_text.each { |t| fps_sum += t.split()[-1].to_f }
      fps_sum = fps_sum.round(4)
      fps_avg = (fps_sum / fps_text.size).round(4)

      unless fps_arr.empty?
        @sum << fps_avg
        fps_arr << fps_text.size
        fps_arr << fps_sum
        fps_arr << fps_avg
        return fps_arr
      end
    end
  end

  def alive?(head, tail)
    alive_arr = Array.new
    if head.empty? && tail.empty?
      puts "without timestamp -- head|tail: #{head}|#{tail}, exit"
      Process.exit -1
    else
      h = Time.parse(head[1])
      t = Time.parse(tail[1])
      alive_arr << head[1]
      alive_arr << tail[1]
      alive_arr << t-h
      alive_arr << (Time.now - h).round(2)
      return alive_arr
    end
  end

  def readfps(fps)
    if fps.is_a? Array
      name = %w(instance pid start end cost now samples sum avg)
      if name.size == fps.size
        str = ""
        name.map.with_index do |x, i|
          if x == "cost"
            str += "#{x}:#{fps[i]} s, "
          elsif x == "now"
            str += "#{x}:#{fps[i]} s, "
          else
            str += "#{x}:#{fps[i]} , "
          end
        end
        return str
      end
    else
      puts "readfps failed, fps is empty"
    end
  end

  def total
    total = 0.0
    @sum.each { |s| total = total + s }
    total = total.round(4)
    File.open(@log,"a") { |io| io.puts "total: #{total}, avg(/#{@sum.size}):#{(total/@sum.size).round(4)}" }
    puts "total: #{total}, avg(/#{@sum.size}):#{(total/@sum.size).round(4)}"
  end

  def parse
    good_arr = Array.new
    bad_arr = Array.new
    @fps_arr.each do |f|
      cost = f[4]
      now = f[5]
      if now - cost < 3
        good_arr << f
      else
        bad_arr << f
      end
    end

    write_file "good instances"
    parse_fps(good_arr)
    write_file "bad instances"
    parse_fps(bad_arr)
  end

  def parse_fps(fps)
    avg = 0.0
    fps.each do |f| 
      write_file readfps(f)
      avg += f[-1]
    end
    avg = avg.round(4)
    write_file "total: #{avg}, avg(/#{fps.size}):#{(avg/fps.size).round(4)}"
  end

  def write_file(str = "")
    File.open(@log, "a") do |io| 
      puts "#{str}"
      io.puts str
    end
  end

end

def main
  app = "com.tencent.tmgp.sgame"
  a = FPS.new(app)
  #data_dir = "/home/media/ACGSS_SG1_LR_LT_4.2_Dev_666/aic-cg/workdir"
  data_dir = "/home/media/zhiwei/workdir"
  length = 10
  log = a.log
  rmpid = Process.spawn("rm -rf #{log}")
  Process.wait rmpid

  #(145..150).each do |num|
  #(0..151).each do |num|
  aic_arr = %w(0 36 72 108)
  #(0..143).each do |num|
  aic_arr.each do |num|
    instance = "android#{num}"
    instance_arr = Array.new
    status = a.instance_check(instance)
    #puts "status: #{status}"
    if status == "running"
      pid = 0
      pid = a.pid(instance)
      #puts "pid: #{pid}"
      if pid == -1
        puts "instance:#{num} can't find the pid of #{a.app}"
        next
      else
        aplog = File.join(data_dir,"data#{num}/logs/aplog")
        temp = a.log_fps(aplog,pid,length)
        f = temp.uniq
        if f[0] == "0"
          puts "temp is empty, next"
          next
        else
          instance_arr << num
          instance_arr << pid
          temp.each { |i| instance_arr << i }
          a.fps_arr << instance_arr
          File.open(a.log,"a") do |io| 
            str = a.readfps(instance_arr)
            puts str
            io.puts str
          end
        end
      end
    else
      puts "the status of #{instance} is #{status}(no running)"
      next
    end
  end
  a.total
  a.parse

end

main
