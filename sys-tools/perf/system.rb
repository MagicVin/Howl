#!/usr/bin/env ruby
########################<basic.rb########################
class Basic
  attr_reader :cpu
  attr_reader :os
  attr_reader :dimm
  attr_reader :bios
  attr_reader :disk
  attr_reader :board


  def initialize 
    @cpu = Hash.new
    @os = Hash.new
    @dimm = Hash.new
    @bios = Hash.new
    @disk = Hash.new
    @board = Hash.new
    @cpu[:name] = "" # name of cpu
    @cpu[:socket] = 0 # number of socket
    @cpu[:core] = 0 # number of vcore
    @cpu[:numa] = 0 # number of numa node
    @os[:name] = "" # name of os
    @os[:kernel] = "" # version of kernel
    @os[:cmdline] = "" # cmdline of kernel
    @dimm[:size] = Array.new # size of dimmory
    @dimm[:type] = Array.new # type of dimmory
    @dimm[:speed] = Array.new # speed of dimmory
    @dimm[:count] = 0 # count of dimmory
    @bios[:version] = "" # version of bios
    @bios[:date] = "" # release date of bios
    @bios[:size] = 0 # rom size of bios
  end

  def getcpu
    cmds = "lscpu"
    IO.popen(cmds) do |io|
      while line = io.gets
        @cpu[:name] = line.split()[2..-1].join(" ") if /Model name/ =~ line
        @cpu[:socket] = line.split()[-1] if /Socket/ =~ line
        @cpu[:core] = line.split()[-1] if /^CPU\(s\):/ =~ line
        @cpu[:numa] = line.split()[-1] if /^NUMA node\(s\):/ =~ line
      end
    end
    end

  def getos
    IO.popen("cat /etc/os-release") do |io|
      while line = io.gets
        @os[:name] += line.gsub(/['=','"']/," ").split[1..-1].join(" ") if /^NAME=/ =~ line || /^VERSION=/ =~ line
      end
    end

    kernel_str = IO.popen("cat /proc/cmdline").read.split(" ro ")
    @os[:kernel] = kernel_str[0].split[0].gsub(/^BOOT_IMAGE.*vmlinuz-/,"")
    @os[:cmdline] = kernel_str[1]
  end

  def getdimm
    IO.popen("dmidecode -t memory") do |io|
      while line = io.gets
        next if /No Module Installed/ =~ line
        next if /Unknown/ =~ line
        next if /Clock/ =~ line
        @dimm[:size] << line.split[1..-1].join() if /Size/ =~ line
        @dimm[:type] << line.split[-1] if /Type: DDR/ =~ line
        @dimm[:speed] << line.split[1..-1].join() if /Speed/ =~ line
      end
    end
    @dimm[:count] = @dimm[:size].size
    @dimm.each { |k,v| v.uniq! if v.is_a? Array }
  end

  def getbios
    IO.popen("dmidecode -t 0") do |io|
      while line = io.gets
        @bios[:version] = line.split[-1] if /Version/ =~ line
        @bios[:date] = line.split[-1] if /Date/ =~ line
        @bios[:size] = line.split[-2..-1] if /ROM Size/ =~ line
      end
    end
    #@bios[:version] = File.read("/sys/devices/virtual/dmi/id/bios_version")
    #@bios[:date] = File.read("bios_date")
  end

  def getdisk
    IO.popen("fdisk -l",:err=>"/dev/null") do |io|
      while line = io.gets
        if /^Disk.*sectors/ =~ line
          @disk[line.split()[1].gsub(":","")] = line.split()[2..3].join().gsub(",","") # /dev/sda 960.2GB
        end
      end
    end
  end

  def getboard
    @board[:name] = File.read("/sys/devices/virtual/dmi/id/board_name")
    @board[:board_vendor] = File.read("/sys/devices/virtual/dmi/id/board_vendor")
    @board[:board_version] = File.read("/sys/devices/virtual/dmi/id/board_version")
  end

  def show
    puts "System Basic Info"
    out(@cpu,"cpu")
    out(@os,"os")
    out(@dimm,"dimm")
    out(@bios,"bios")
    out(@disk,"disk")
    out(@board,"board")
  end

  def out(hash,tag)
    puts "#{tag.upcase} Info:"
    hash.each do |k,v| 
      puts "#{tag} #{k.to_s}: #{v}" unless v.is_a? Array
      puts "#{tag} #{k.to_s}: #{v.join}" if v.is_a? Array
    end  
  end

  def xml
    outxml(@cpu,"cpu")
    outxml(@os,"os")
    outxml(@dimm,"dimm")
    outxml(@bios,"bios")
    outxml(@disk,"disk")
    outxml(@board,"board")
  end

  def outxml(hash,tag)
    puts "#{tag.upcase} Info,"
    hash.each do |k,v| 
      puts "#{tag} #{k.to_s}, #{v}" unless v.is_a? Array
      puts "#{tag} #{k.to_s}, #{v.join}" if v.is_a? Array
    end
  end

end

########################basic.rb\>########################

########################<sar.rb########################
class SAR
  attr_reader :sar_avg
  def initialize
    @sar_avg = Array.new
  end

  def getlog(cmds,log)
    IO.popen(cmds) do |io|
      while line = io.gets 
        File.open(log, "a") { |file| file.puts line }
      end
    end
  end

  def cpu_util(log)
    rmlog(log)
    cmds = "sar -u 1 4"
    getlog(cmds,log)
  end

  def net_util(log)
    rmlog(log)
    cmds = "sar -n DEV 1 4"
    getlog(cmds,log)
  end

  def sar_util(log)
    rmlog(log)
    cmds = "sar -u -n DEV -m CPU 1 4"
    getlog(cmds,log)
  end

  def rmlog(log)
    if File.exist? log
      rmid = Process.spawn("sudo rm -rf #{log}")
      Process.wait rmid
    end
  end

  def parse_log(log)
    File.open(log,"r") do |file|
      while line = file.gets
        next if /veth/ =~ line
        @sar_avg << line.split() if /Average/ =~ line
      end
    end
  end

  def show
    puts "SAR Info"
    @sar_avg.each { |i| puts i.join(" ")}
  end

  def xml
    #puts "SAR Info"
    #@sar_avg.each { |i| puts i[1..-1].join(", ")}
    @sar_avg.each do |i|
      s = ""
      i.each_with_index do |k,index|
        puts "SAR CPU Util" if k.include? "idle"
        puts "SAR Network Util" if k.include? "IFACE" 
        puts "SAR CPU Freq" if k.include? "MHz"
        s += "#{k.to_s.gsub(":","")} " if index == 0
        s += "#{k} ," unless index == 0
      end
      puts s
    end
  end

end

########################sar.rb\>########################

########################<mpstat.rb########################
class MPSTAT
  attr_reader :mpstat_avg
  def initialize 
    @mpstat_avg = Array.new
  end

  def getlog(log)
    rmlog(log)
    cmds = "mpstat 1 4"
    IO.popen(cmds) do |io|
      while line = io.gets
        File.open(log,"a") { |file| file.puts line }
      end
    end

  end

  def rmlog(log)
    if File.exist? log
      rmid = Process.spawn("sudo rm -rf #{log}")
      Process.wait rmid
    end
  end

  def parse_log(log)
    File.open(log, "r") do |file|
      while line = file.gets
        next if /^Linux/ =~ line
        @mpstat_avg << line.split() if /CPU/ =~ line || /Average/ =~ line
      end
    end
  end

  def show 
    puts "MPSTAT Info"
    @mpstat_avg.each { |i| puts i.join(" ") }
  end

  def xml
    puts "MPSTAT Info"
    #@mpstat_avg.each { |i| puts i.join(" ,") }
    s = ""
    @mpstat_avg.each_with_index do |i,index|
      if index == 0
        i.each_with_index do |k,idx|
          s += "#{k} " if idx == 0
          s += "#{k} ," unless idx ==0
        end
        puts s
      else
        puts i.join(" ,")
      end
    end
  end

end

########################mpstat.rb\>########################

########################<mem.rb########################
class Meminfo
  attr_reader :mem
  def initialize
    @mem = Hash.new
    @mem[:total] = 0
    @mem[:free] = 0
    @mem[:buff_cache] = 0

  end

  def getlog(log)
    mem_path = "/proc/meminfo"
    rmlog(log)
    File.open(mem_path, "r") do |file|
      while line = file.gets
        File.open(log,"a") { |f| f.puts line }
        @mem[:total] += line.split()[1].to_i if /^MemTotal/ =~ line || /^SwapTotal/ =~ line 
        @mem[:free] += line.split()[1].to_i if /^MemFree/ =~ line || /^SwapFree/ =~ line
        @mem[:buff_cache] += line.split()[1].to_i if /^Buffers/ =~ line || /^Cached/ =~ line || /^Slab/ =~ line
      end
    end
    
  end

  def rmlog(log)
    if File.exist? log
      rmid = Process.spawn("sudo rm -rf #{log}")
      Process.wait rmid
    end
  end

  def show
    puts "Mem Info"
    @mem.each { |k,v| puts "#{k}: #{(v/1024/1024.to_f).round(1)}G"}
  end

  def xml
    puts "Mem Info"
    @mem.each { |k,v| puts "#{k}, #{(v/1024/1024.to_f).round(1)}G"}
  end

end

########################mem.rb\>########################

########################<numa.rb########################
class NUMA
  attr_reader :numa_sum
  def initialize
    @numa_sum = Array.new
  end

  def getlog_numa_mem(log)
    rmlog(log)
    cmds = "numactl --hardware"
    IO.popen(cmds) do |io|
      while line = io.gets 
        File.open(log, "a") { |file| file.puts line }
      end
    end
  end

  def rmlog(log)
    if File.exist? log
      rmid = Process.spawn("sudo rm -rf #{log}")
      Process.wait rmid
    end
  end

  def parse_log(log)
    File.open(log, "r") do |file|
      while line = file.gets
      next if line.split().size < 5
      next if /cpu/ =~ line
      @numa_sum << line.split(":") if /node.*:/ =~ line
      end
    end
  end

  def show
    puts "NUMA Info"
    @numa_sum.each { |i| puts i.join(" ") }
  end

  def xml
    puts "NUMA Info"
    @numa_sum.each { |i| puts i.join(" ,") }
  end

end

########################numa.rb\>########################

########################<disk.rb########################
class Disk
  attr_reader :disk
  def initialize
    @disk = Hash.new
    @disk[:title] = Array.new
    @disk[:root] = Array.new # / 
    @disk[:home] = Array.new
    @disk[:boot] = Array.new
  end

  def getlog(log)
    rmlog(log)
    cmds = "df -Th"
    IO.popen(cmds) do |io|
      while line = io.gets
        File.open(log, "a") { |file| file.puts line }
        @disk[:title] = line.gsub(/Mounted.*on/,"Mounted_on").split()if /Filesystem/ =~ line
        @disk[:root] = line.split() if /\/$/ =~ line
        @disk[:home] = line.split() if /home$/ =~ line
        @disk[:boot] = line.split() if /boot$/ =~ line
      end
    end
  end

  def rmlog(log)
    if File.exist? log
      rmid = Process.spawn("sudo rm -rf #{log}")
      Process.wait rmid
    end
  end

  def show
    puts "Disk Info"
    @disk.each { |k,v| puts "#{k.to_s}: #{v.join(" ")}" unless v.empty? }
  end

  def xml
    puts "Disk Info"
    @disk.each { |k,v| puts "#{k.to_s}, #{v.join(" ,")}" unless v.empty? }
  end


end

########################disk.rb\>########################

########################<iostat.rb########################
class IOSTAT
  attr_reader :iostat
  def initialize
    @iostat = Array.new

  end

  def getlog(log)
    rmlog(log)
    cmds = "iostat -d -m -p -x -y  1 3"
    IO.popen(cmds) do |io|
      while line = io.gets
        File.open(log,"a") { |file| file.puts line }
        next if /Linux/ =~ line || /^$/ =~ line
        @iostat << line.split() 
      end
    end
  end

  def show 
    puts "Iostat Info"
    @iostat.each { |i| puts "#{i.join(" ")}" } 
  end

  def xml
    puts "Iostat Info"
    @iostat.each { |i| puts "#{i.join(" ,")}" } 
  end

  def rmlog(log)
    if File.exist? log
      rmid = Process.spawn("sudo rm -rf #{log}")
      Process.wait rmid
    end
  end
end

########################iostat.rb\>########################

########################<ptu.rb########################
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
    

    puts "PTU Info"
    #puts cpu_title.join(" ,")

    #cpu_raw.each do |k,v|
    #  v.each { |i| puts i.join(" ,") }
    #  str = ""
    #  cpu_data[k].each do |n,c|
    #    cpu_title.each do |i|
    #      str += "#{c} ," if n == i
    #    end
    #  end
    #  puts str 
    #end

    puts cpu_title[1..-1].join(" ,")

    cpu_data.each do |k,v|
      str = ""
      cpu_title.each do |i|
        #str += "#{v[i].to_s} ," if v.keys.include? i
        if v.keys.include? i
          str += "#{v[i].to_s} " if /avg/ =~ v[i].to_s 
          str += "#{v[i].to_s} ," unless /avg/ =~ v[i].to_s 
        end
      end
      puts str
    end
  end 

end

########################ptu.rb\>########################

########################<perf.rb########################
class Perf
  attr_reader :perf
  def initialize
    @perf = Hash.new
    @perf[:sys] = Array.new
    @perf[:thread] = Array.new
  end

  def getlog_sys_sched
    unless File.read("/proc/sys/kernel/kptr_restrict").chomp == "0"
      pidd = Process.spawn("echo 0 > /proc/sys/kernel/kptr_restrict")
      Process.wait pidd
    end
    #system("sudo echo 0 > /proc/sys/kernel/kptr_restrict") if File.read("/proc/sys/kernel/kptr_restrict").chomp == "0"
    cmds = "perf sched record -a -g -- sleep 1"
    sys_pid = Process.spawn(cmds)
    Process.wait(sys_pid)
    File.rename("./perf.data","./perf-sys-sched.txt")
  end

  def getlog_thread_sched(pid)
    unless File.read("/proc/sys/kernel/kptr_restrict").chomp == "0"
      pidd = Process.spawn("echo 0 > /proc/sys/kernel/kptr_restrict")
      Process.wait pidd
    end
    cmds = "perf sched record -p #{pid.to_i} -g -- sleep 1"
    thread_pid = Process.spawn(cmds)
    Process.wait(thread_pid)
    File.rename("./perf.data","./perf-thread#{pid}-sched.txt")
  end

  def parselog(log,tag)
    timecmds = "perf sched timehist -s -i #{log}"
    latencycmds = "perf sched latency -s runtime -i #{log}"
    basename = File.basename(log, ".*")
    timelog = File.expand_path(".","#{basename}-timehist.txt")
    latencylog = File.expand_path(".","#{basename}-latency.txt")

    rmlog(timelog)
    
    IO.popen(timecmds) do |io|
      while line = io.gets
        File.open(timelog, "a") { |file| file.puts line } 
        @perf[tag] << line.split() if /Total/ =~ line
      end
    end

    rmlog(latencylog)
    IO.popen(latencycmds) do |io|
      while line = io.gets
        File.open(latencylog, "a") { |file| file.puts line }
        @perf[tag] << line.split() if /TOTAL:/ =~ line
      end
    end
  end

  def rmlog(log)
    if File.exist? log
      rmid = Process.spawn("sudo rm -rf #{log}")
      Process.wait rmid
    end
  end

  def show
    puts "Perf Info"
    @perf.each do |k,v| 
      v.each do |i| 
        puts "#{k} #{i.join(" ").gsub(/[':','|']/,"")}" unless i.include? "ms"
        puts "#{k} #{i.join(" ").gsub(/[':','|']/,"").gsub("ms","ms, switch")}" if i.include? "ms"
      end
    end
  end

  def xml
    puts "Perf Info"
    @perf.each do |k,v| 
      v.each do |i| 
        puts "#{k} #{i.join(" ").gsub(/:/," ,")}" unless i.include? "ms"
        puts "#{k} #{i.join(" ").gsub(/:/," ,").gsub("|","").gsub("ms","ms, switch")}" if i.include? "ms"
      end
    end
  end
end

########################perf.rb\>########################

def getlog
  sar = SAR.new
  sar_log = "./sar-util.txt"
  sar.sar_util(sar_log)
  #sar.parse_log(sar_log)
  #sar.show
  #sar.xml

  mpstat = MPSTAT.new
  mpstat_log = "./mpstat.txt"
  mpstat.getlog(mpstat_log)
  #mpstat.parse_log(mpstat_log)
  #mpstat.show
  #mpstat.xml

  #mem = Meminfo.new
  #memlog = "./mem.txt"
  #mem.getlog(memlog)

  numa = NUMA.new
  numa_log = "./numa-mem.txt"
  numa.getlog_numa_mem(numa_log)
  #numa.parse_log(numa_log)
  #numa.show
  #numa.xml

  #disk = Disk.new
  #disk_log = "./disk.txt"
  #disk.getlog(disk_log)

  #iostat = IOSTAT.new
  #iostat_log = "./iostat.txt"
  #iostat.getlog(iostat_log)


  ptu_dir = "/root/ptu"
  ptu_exe = File.join(ptu_dir, "ptu")
  ptu_driver = File.join(ptu_dir, "driver/ptusys/ptusys.ko")
  ptu_log = "./ptu-data.txt"
  ptu = Ptu.new(ptu_exe, ptu_driver)
  ptu.getlog(ptu_log)
  #ptu.parse_cpu(ptu_log)

  perf = Perf.new
  pid = "26001"
  sys_sched_log = "./perf-sys-sched.txt"
  thread_sched_log = "./perf-thread#{pid}-sched.txt"
  perf.getlog_sys_sched
  perf.getlog_thread_sched(pid)
  #perf.parselog(sys_sched_log,:sys)
  #perf.parselog(thread_sched_log,:thread)
  #perf.show
  #perf.xml
end

def show
  basic = Basic.new
  basic.getcpu
  basic.getos
  basic.getdimm
  basic.getbios
  basic.getdisk
  basic.getboard
  #basic.show
  basic.xml

  sar = SAR.new
  sar_log = "./sar-util.txt"
  sar.parse_log(sar_log)
  #sar.show
  sar.xml

  mpstat = MPSTAT.new
  mpstat_log = "./mpstat.txt"
  #mpstat.getlog(mpstat_log)
  mpstat.parse_log(mpstat_log)
  #mpstat.show
  mpstat.xml

  mem = Meminfo.new
  mem_log = "./mem.txt"
  mem.getlog(mem_log)
  #mem.show
  mem.xml

  numa = NUMA.new
  numa_log = "./numa-mem.txt"
  #numa.getlog_numa_mem(numa_log)
  numa.parse_log(numa_log)
  #numa.show
  numa.xml

  disk = Disk.new
  disk_log = "./disk.txt"
  disk.getlog(disk_log)
  #disk.show
  disk.xml

  iostat = IOSTAT.new
  iostat_log = "./iostat.txt"
  iostat.getlog(iostat_log)
  #iostat.show
  iostat.xml

  ptu_dir = "/root/ptu"
  #ptu_exe = "#{ptu_dir}/ptu"
  ptu_exe = File.join(ptu_dir, "ptu")
  ptu_driver = File.join(ptu_dir, "driver/ptusys/ptusys.ko")
  ptu_log = "./ptu-data.txt"
  ptu = Ptu.new(ptu_exe, ptu_driver)
  ptu.parse_cpu(ptu_log)

  perf = Perf.new
  pid = "26001"
  sys_sched_log = "./perf-sys-sched.txt"
  thread_sched_log = "./perf-thread#{pid}-sched.txt"
  #perf.getlog_sys_sched
  #perf.getlog_thread_sched(pid)
  perf.parselog(sys_sched_log,:sys)
  perf.parselog(thread_sched_log,:thread)
  #perf.show
  perf.xml
end

def main 
  unless ARGV.size == 1
    puts "needs action: [get|put]"
    puts "  e.g. #{__FILE__} get"
    puts "  e.g. #{__FILE__} put"
    Process.exit -1
  end
  
  if ARGV[0] == "get"
    getlog
  elsif ARGV[0] == "put"
    show
  elsif ARGV[0] == "all"
    getlog
    sleep 2
    show
  end

end

main
