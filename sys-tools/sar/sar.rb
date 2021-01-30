#!/usr/bin/env ruby
#Author: xinx.e.zhang@intel.com
#Date: Jan 24, 2021
#Version: v1.0

class Sar
  attr_reader :options
  attr_accessor :items
  attr_accessor :logs
  attr_accessor :save
  attr_reader :list
  def initialize
    sar_options
    @items = Hash.new
    @logs = ""
    @save = {
      sum: "",
      avg: "",
    }
    @list = [
      #CPU
      :u,
      :mcpu,
      :w,
      :v,
      :I,
      :q,
      :y,
      #MEM
      :r,
      :R,
      :H,
      :B,
      :S,
      :W,
      #I/O
      :b,
      :d,
      #Network
      :ndev,
      :nedev,
      :nnfs,
      :nnfsd,
      :nsock,
      :nip,
      :neip,
      :nicmp,
      :neicmp,
      :ntcp,
      :netcp,
      :nudp,
      :nsock6,
      :nip6,
      :neip6,
      :nicmp6,
      :neicmp6,
      :nudp6,
    ]
  end

  def sar_options
    @options = Hash.new
    @options = {
      A: {
        title: "All System Activities",
        cmd: "-A -p",
        tag: "",
      },
      B: {
        title: "System page statistics between disk and memory",
        cmd: "-B",
        tag: "pgpgin",
      },
      b: {
        title: "Overall physical devices I/O statistics",
        cmd: "-b",
        tag: "bwrtn",
      },
      d: {
        title: "Block device(such as disk) I/O Activities ",
        cmd: "-d -p",
        tag: "rd_sec",
      },
      H: {
        title: "Hugepages(in KB) utilization statistics",
        cmd: "-H",
        tag: "kbhugfree",
      },
      I: {
        title: "Interrupts received statistics",
        cmd: "-I ALL",
        tag: "INTR",
      },
      mcpu: {
        title: "Instantaneous CPU clock frequency in MHz(the value depends on power settings)",
        cmd: "-m CPU",
        tag: "MHz",
      },
      ndev: {
        title: "Network devices I/O statistics",
        cmd: "-n DEV",
        tag: "rxpck",
      },
      nedev: {
        title: "Network devices Failures(errors) statistics",
        cmd: "-n EDEV",
        tag: "rxerr",
      },
      nnfs: {
        title: "NFS Client activities statistics",
        cmd: "-n NFS",
        tag: " call",
      },
      nnfsd: {
        title: "NFS Server activities statistics",
        cmd: "-n NFSD",
        tag: "scall",
      },
      nsock: {
        title: "Sockets activities statistics(IPv4)",
        cmd: "-n SOCK",
        tag: "totsck",
      },
      nip: {
        title: "IPv4 network traffic statistics",
        cmd: "-n IP",
        tag: "irec/s",
      },
      neip: {
        title: "IPv4 network errors statistics",
        cmd: "-n EIP",
        tag: "ihdrerr",
      },
      nicmp: {
        title: "ICMPv4 network traffic statistics",
        cmd: "-n ICMP",
        tag: "imsg/s",
      },
      neicmp: {
        title: "ICMPv4 error messages statistics",
        cmd: "-n EICMP",
        tag: "ierr/s",
      },
      ntcp: {
        title: "TCPv4 network traffic statistics",
        cmd: "-n TCP",
        tag: "active/s",
      },
      netcp: {
        title: "TCPv4 network errors statistics",
        cmd: "-n ETCP",
        tag: "atmptf",
      },
      nudp: {
        title: "UDPv4 network traffic statistics",
        cmd: "-n UDP",
        tag: "idgm/s",
      },
      nsock6: {
        title: "Sockets activities statistics(IPv6)",
        cmd: "-n SOCK6",
        tag: "tcp6sck",
      },
      nip6: {
        title: "IPv6 network traffic statistics",
        cmd: "-n IP6",
        tag: "irec6/s",
      },
      neip6: {
        title: "IPv6 network errors statistics",
        cmd: "-n EIP6",
        tag: "ihdrer6/s",
      },
      nicmp6: {
        title: "ICMPv6 network tracffic statistics",
        cmd: "-n ICMP6",
        tag: "imsg6/s",
      },
      neicmp6: {
        title: "ICMPv6 error messages statistics",
        cmd: "-n EICMP6",
        tag: "ierr6/s",
      },
      nudp6: {
        title: "UDPv6 network traffic statistics",
        cmd: "-n UDP6",
        tag: "idgm6/s",
      },
      q: {
        title: "Queue length and load averages statistics",
        cmd: "-q",
        tag: "runq-sz",
      },
      R: {
        title: "Memory pages statistics",
        cmd: "-R",
        tag: "frmpg/s",
      },
      r: {
        title: "Memory utilization statistics",
        cmd: "-r",
        tag: "kbmemfree",
      },
      S: {
        title: "Swap space utilization statistics",
        cmd: "-S",
        tag: "kbswpfree",
      },
      u: {
        title: "CPU utilization statistics",
        cmd: "-u ALL",
        tag: "%guest",
      },
      v: {
        title: "Inode and file handles and other kernel tables statistics",
        cmd: "-v",
        tag: "dentunusd",
      },
      W: {
        title: "Swap pages statistics",
        cmd: "-W",
        tag: "pswpin",
      },
      w: {
        title: "Task creation and system switching statistics",
        cmd: "-w",
        tag: "proc",
      },
      y: {
        title: "TTY device statistics",
        cmd: "-y",
        tag: "TTY",
      },
    }
  end

  def parse_cmds(option = "", interval = 1, count = 3)
    unless option.instance_of? String
      puts "  option must be a string"
      return 1
    end

    unless @options.keys.include? option.to_sym
      puts "  unsupported option: \"#{option}\", can't be performed"
      return 1
    end

    if @options.keys.include? option.to_sym
      @items.clear
      @items = {
        title: "#{@options[option.to_sym][:title]}",
        cmds: "sar #{@options[option.to_sym][:cmd]} #{interval} #{count}",
        logs: "./sar#{@options[option.to_sym][:cmd].split().join("")}.txt",
        tag: "#{@options[option.to_sym][:tag]}",
      }
    end
  end

  def data_get
    if File.exist? @items[:logs]
      rmid = Process.spawn("sudo rm -rf #{@items[:logs]}")
      Process.wait rmid
    end

    IO.popen(@items[:cmds]) do |io|
      while line = io.gets
        File.open(@items[:logs],"a") { |file| file.puts line }
      end
    end
  end

  def line_parse
    tag_arr = Array.new
    line_arr = Array.new
    if File.exist? @logs
      line_num = 0
      File.open(@logs, 'r') do |file|
        while line = file.gets
          line_num += 1
          #next if (/^Linux/ =~ line) || (/^$/ =~ line)
          tag_arr << line_num if /#{@items[:tag]}/ =~ line
        end
      end
      
      return -1 if tag_arr.empty?

      line_num = 0
      line_close = 1
      File.open(@logs, 'r') do |file|
        while line = file.gets
          line_num += 1
          if /^$/ =~ line
            line_close = 1
            next 
          end

          if tag_arr.include? line_num
            line_close = 0
            next
          end

          if line_close == 0 
            line_arr << line_num if /:/ =~ line
          end

        end
      end

      return "#{tag_arr[0]},#{line_arr.join(",")}"

    end
  end

  def raw_read(content,sum = 1)
    str = ""
    unless /Average/ =~ content
      if sum == 0
        content.split().each_with_index do |v,i|
          str += "#{v}_" if i == 0
          str += "#{v} " unless i == 0
        end
      else
        if /#{@items[:tag]}/ =~ content
          content.split().each_with_index do |v,i|
            str += "#{v}_" if i == 0
            str += "#{v} " unless i == 0
          end
        end
      end
    else
      str = content.split().join(" ")
    end

    return str
  end

  def csv_read(content,sum = 1)
    str = ""
    unless /Average/ =~ content
      if sum == 0
        content.split().each_with_index do |v,i|
          str += "#{v}_" if i == 0
          str += "#{v} ," unless i == 0
        end
      else
        if /#{@items[:tag]}/ =~ content
          content.split().each_with_index do |v,i|
            str += "#{v}_" if i == 0
            str += "#{v}," unless i == 0
          end
        end
      end
    else
      str = content.split().join(",")
    end

    return str
  end

  def del_file(file)
    if File.exist? file
      rmid = Process.spawn("sudo rm -rf #{file}")
      Process.wait rmid
    end
  end

  def log_csv(sum = "sum-sar.csv", avg = "avg-sar.csv")
    del_file(sum)
    del_file(avg)
    @save[:sum] = sum
    @save[:avg] = avg
  end

  def data_put(log = "")
    @logs = log unless log.empty?
    @logs = @items[:logs] if log.empty?
    
    log_all = 0
    lines = line_parse
    
    if lines == -1
      puts "no data gets from: [cmds: #{@items[:cmds]}, log: #{@logs}]"
    else
      line_num = 0 
      puts "#{@items[:title]}"
      File.open(@save[:sum], "a") { |file| file.puts "#{@items[:title]}" } unless @save[:sum].empty?
      File.open(@logs, 'r') do |file|
        while line = file.gets
          line_num += 1
          if lines.split(',').include? line_num.to_s
              data = raw_read(line,0)
              unless data.empty?
                puts data
                File.open(@save[:sum], "a") { |file| file.puts csv_read(line,0) } unless @save[:sum].empty?
              end
          end
        end
      end
  
      line_num = 0 
      File.open(@save[:avg], "a") { |file| file.puts "#{@items[:title]}" } unless @save[:avg].empty?
      File.open(@logs, 'r') do |file|
        while line = file.gets
          line_num += 1
          if lines.split(',').include? line_num.to_s
              data = csv_read(line,1)
              unless data.empty?
                File.open(@save[:avg], "a") { |file| file.puts data } unless @save[:avg].empty?
              #puts data 
              end
          end
        end

      end
    end
    
  end

  def data_head(log = "")
    @logs = log unless log.empty?
    @logs = @items[:logs] if log.empty?
    if File.exist? @logs
      File.open(@logs, 'r') do |file|
        while line = file.gets
          return line.gsub(' CPU','CPU') if /^Linux/ =~ line
        end
      end
    end
  end
end

def main
  sar = Sar.new
  sar.log_csv #logging output
  sar.parse_cmds("A") #enabling all of the system activities statistics
  log = sar.items[:logs]
  sar.data_get #logging the file
  sar.list.each do |key|
    sar.parse_cmds(key.to_s)
    sar.data_put(log)
  end
end

main
