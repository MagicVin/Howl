#!/usr/bin/env ruby
# xinx.e.zhang@intel.com
# June 17, 2021
# v1.1
require 'optparse'

module Map
  def base_cpu(core = 192, hthread = 2, skt = 4, instance = 144, threads = 4)
    phy_cpu = core / hthread
    skt_phy_cpu = phy_cpu / skt

    ht = Array.new
    hthread.times do |i|
      ht[i] = Array.new 
      first_cpu = i * phy_cpu
      last_cpu = (i+1) * phy_cpu - 1 
      ht[i].concat((first_cpu..last_cpu).to_a)
    end
    
    instance_box = (threads / (core / instance.to_f )).to_i

    ins_count = 0
    ins_group = 0
    core_head = 0
    core_tail = 0
    core_range = ""
    File.write("cpu_#{instance}.txt", "") if File.exist? "cpu_#{instance}.txt"

    instance.times do |ins|
      if ins % instance_box == 0
        ins_count = 0
        core_range = ""
        ins_group = ins/instance_box
        core_head = ins_group * (threads / hthread)
        core_tail = core_head + (threads / hthread) - 1 
        #puts "#{ins_group} group -- head: #{core_head} - tail: #{core_tail}"
        ht.each_with_index do |h, idx|
          if core_head < h.size
            if idx < (ht.size - 1)
              core_range += "#{h[core_head..core_tail].join(',')},"
            else
              core_range += "#{h[core_head..core_tail].join(',')}"
            end
          end
        end
      else
        ins_count += 1
      end
      puts "instance: #{ins} --  range: #{core_range}"
      File.open("cpu_#{instance}.txt", 'a') { |io| io.puts core_range }
    end
  end
end

class Options
  attr_reader :options 

  def initialize 
    @options = Hash.new
    parse_options
  end
  
  def parse_integer(str)
    if str && str.is_a?(String)
      str.to_i if /^[0-9]+$/ =~ str
    end
  end

  def parse_options
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: ./#{File.basename(__FILE__)} [options]"
      opts.program_name = "CPU_MAP"
      opts.separator "\nRequired options:"
      opts.on("-c", "--core-num <cpu num>", "total cpu number") { |v| @options[:cpu_num] = parse_integer(v) }
      opts.on("-t", "--hyper-thread <hthread num>", "thread number per physical cpu") { |v| @options[:hthread_num] = parse_integer(v) }
      opts.on("-s", "--socket-num <socket num>", "total socket number") { |v| @options[:skt_num] = parse_integer(v) }
      opts.on("-i", "--instance <instance num>", "total instance number") { |v| @options[:instance_num] = parse_integer(v) }
      opts.on("-p", "--processor <processor num>", "total processor number per instance") { |v| @options[:processor_num] = parse_integer(v) }
      opts.separator "\nMisc options:"
      opts.on("-h", "--help", "Show this message") { puts opts; exit }
      opts.separator "\nProgram info: Intel CloudGaming Project[cpu map] (xinx.e.zhang@intel.com) "

    end
    
    if ARGV.size == 0 
      puts opts
      exit
    else
      opts.parse!(ARGV)
      puts "./#{File.basename(__FILE__)} -c #{@options[:cpu_num]} -t #{@options[:hthread_num]} -s #{@options[:skt_num]} -i #{@options[:instance_num]} -p #{@options[:processor_num]}"
    end
  end
end


def main
  include Map
  options = Options.new

  base_cpu(core = options.options[:cpu_num], 
    hthread = options.options[:hthread_num], 
    skt = options.options[:skt_num],
    instance = options.options[:instance_num],
    thread = options.options[:processor_num]
    )
end

main
