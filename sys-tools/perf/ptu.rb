#!/usr/bin/env ruby
class Ptu
  attr_accessor :ptu
  attr_reader :driver
  
  def initialize(ptu = "", driver = "")
    unless ptu.empty? && driver.empty? 
      @ptu = ptu if File.executable_real? ptu
      @driver = driver
    else
      out "this program needs to know where is the (ptu)tool"
      Process.exit -1
    end
  end

  def out(msg)
    puts "  #{msg}"
  end

  def show
    out "ptu: #{@ptu}"
  end

  def install_driver(ko = "")
    if ko.empty? 
      out "ptu driver(ptusys.ko) is missing"
      Process.exit -1
    end

    if File.basename(ko) == "ptusys.ko"
      rmpid = Process.spawn("sudo rmmod ptusys > /dev/null 2>&1")
      Process.wait rmpid
      inspid = Process.spawn("sudo insmod #{ko}")
      Process.wait inspid
      if IO.popen("lsmod").read.include? "ptusys"
        out "ptusys driver is installed"
      else
        out "ptusys driver is failed"
        Process.exit -1
      end

    else
      out "#{ko} is not the driver the ptu needs(ptusys.ko)"
      Process.exit -1
    end
  end

  def getlog(log)
    if File.exist? log
      rmid = Process.spawn("sudo rm -rf #{log}")
      Process.wait rmid
    end
    
    install_driver(@driver)
    cmds = "#{@ptu} -mon -q -t 4"
    IO.popen(cmds) do |io|
      while line = io.gets 
        File.open(log, "a") { |f| f.puts line }
      end
    end
  end

  def parse_title(log)
    File.open(log, "r") do |io|
      while line = io.gets
        return line.split()[1..-1] if /Index/ =~ line
      end
    end
  end

  def title_type(type, title)
      return (title - %w(Cor Thr MC Ch Sl)) if %w(CPU MEM).include? type
  end

  def parse_cpu(log)
    cpu = Array.new
    cpu_id = Array.new
    cpu_raw = Hash.new
    cpu_avg = Hash.new
    cpu_data = Hash.new

    File.open(log, "r") do |io|
      while line = io.gets
        cpu << line.split() if /CPU/ =~ line
      end
    end

    title = parse_title(log)
    cpu_title = title_type("CPU",title)

    cpu.each { |i| cpu_id << i[1] if i[1] =~ /CPU/ }
    cpu_id.uniq!
    cpu_id.each do |i| 
      cpu_raw[i] = Array.new
      cpu_data[i] = Hash.new
    end

    cpu.each { |i| cpu_raw[i[1]] << i if cpu_raw.keys.include? i[1] }
    cpu_raw.each do |k, v|
      v.each { |c| c.select! { |s| /[^-]/ =~ s} }
    end

    cpu_raw.each do |k,v|
      cpu_title.each_with_index do |value,index| 
        if index > 1
          cpu_avg[value] = 0
          if index == 18 || index == 19 # "TStat" "TLog" "0x1" "0x2"
            v.each { |d| cpu_avg[value] += d[index].to_i(16) }
          else
            v.each { |d| cpu_avg[value] += d[index].to_f }
          end
          cpu_avg[value] = (cpu_avg[value] / v.size).round(3)
        elsif index == 0
          cpu_avg[value] = "avg"
          next
        elsif index == 1
          cpu_avg[value] = k
          next
        end
      end
      cpu_avg["TStat"] = "0x#{cpu_avg["TStat"].to_i}"
      cpu_avg["TLog"] = "0x#{cpu_avg["TLog"].to_i}"
      cpu_data[k].merge!(cpu_avg)
    end
    
    p cpu_title.join(" ,")

    cpu_raw.each do |k,v|
      v.each { |i| p i.join(" ,") }
      str = ""
      cpu_data[k].each do |n,c|
        cpu_title.each do |i|
          str += "#{c} ," if n == i
        end
      end
      p str 
    end

    p cpu_title.join(" ,")
    cpu_data.each do |k,v|
      str = ""
      cpu_title.each do |i|
        str += "#{v[i].to_s} ," if v.keys.include? i
      end
      p str
    end
  end 

end

def main
  ptu_dir = "/home/cloud/work/ptu/sw"
  ptu_exe = "#{ptu_dir}/ptu"
  ptu_exe = File.join(ptu_dir, "ptu")
  ptu_log = "./ptu-data.txt"
  ptu_driver = File.join(ptu_dir, "driver/ptusys/ptusys.ko")
  a = Ptu.new(ptu_exe, ptu_driver)
  a.getlog(ptu_log)
  a.parse_cpu(ptu_log)
end

main
