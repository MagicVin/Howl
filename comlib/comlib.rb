#!/usr/bin/env ruby
# xinx.e.zhang@intel.com
# May 10, 2021
# v1.0 

module Common
  def parseStr(list = "")
    # support: 1,2,3,4-9,10-13
    ret = ""
    unless list.empty?
      list.gsub(',',' ').split().each do |i|
        if /-/ =~ i
          i.split().each do |j|
            Range.new(i.split('-')[0].to_i, i.split('-')[1].to_i).each { |r| ret += "#{r.to_s} "} if i.split('-').size == 2
          end
        else
          ret += "#{i.to_s} "
        end
      end
    ret = ret.split().uniq.join(" ")
    end
  end
end

module Cpu
  include Common

  def cpunum
    Dir.entries("/sys/devices/system/cpu").select { |i| i =~ /cpu[0-9]/}.size
  end

  def off(list = "")
    # cpu0 can not be off
    unless list.empty?
      parseStr(list).split().each do |i|
        File.open("/sys/devices/system/cpu/cpu#{i}/online", 'w') { |io| io.puts 0 } if ( i.to_i != 0) && ( i.to_i < cpunum)
      end
      status
    end
  end

  def on(list = "")
    unless list.empty?
      parseStr(list).split().each do |i|
        File.open("/sys/devices/system/cpu/cpu#{i}/online", 'w') { |io| io.puts 1 } if ( i.to_i != 0 ) && ( i.to_i < cpunum)
      end
      status
    end
  end

  def status()
    offline_cpu = File.read("/sys/devices/system/cpu/offline").chomp 
    online_cpu = File.read("/sys/devices/system/cpu/online").chomp
    puts "off cpu: null" if offline_cpu.empty?
    puts "off cpu: #{offline_cpu}" unless offline_cpu.empty?
    puts "on  cpu: #{online_cpu}" unless online_cpu.empty?
  end

  def show
    cpu_info = Array.new
    max_arr = Array.new
    min_arr = Array.new
    gov_arr = Array.new
    Dir.entries("/sys/devices/system/cpu").select { |i| i =~ /cpu[0-9]/}.each do |c|
      min_freq = File.read("/sys/devices/system/cpu/#{c}/cpufreq/scaling_min_freq").chomp
      max_freq = File.read("/sys/devices/system/cpu/#{c}/cpufreq/scaling_max_freq").chomp
      governor = File.read("/sys/devices/system/cpu/#{c}/cpufreq/scaling_governor").chomp
      max_arr << max_freq
      min_arr << min_freq
      gov_arr << governor
      cpu_info << { cpu: c, 
                    min: min_freq,
                    max: max_freq,
                    gov: governor,
                  }
    end
    max = max_arr.uniq.join(", ") 
    min = min_arr.uniq.join(", ")
    gov = gov_arr.uniq.join(", ")
    puts "max freq: #{max}"
    puts "min freq: #{min}"
    puts "governor: #{gov}"
  end
  
  def fix(freq = "")
    unless freq.to_s.empty?
      Dir.entries("/sys/devices/system/cpu").select { |i| i =~ /cpu[0-9]/}.each do |c|    
        min_freq = File.read("/sys/devices/system/cpu/#{c}/cpufreq/scaling_min_freq").chomp
        max_freq = File.read("/sys/devices/system/cpu/#{c}/cpufreq/scaling_max_freq").chomp
        governor = File.read("/sys/devices/system/cpu/#{c}/cpufreq/scaling_governor").chomp
        freq.to_i >= max_freq.to_i ? freq_ord = %w(max min) : freq_ord = %w(min max)
        File.write("/sys/devices/system/cpu/#{c}/cpufreq/scaling_#{freq_ord[0]}_freq", freq)
        File.write("/sys/devices/system/cpu/#{c}/cpufreq/scaling_#{freq_ord[1]}_freq", freq)
        File.write("/sys/devices/system/cpu/#{c}/cpufreq/scaling_governor", "performance") if governor != "performance"
      end
    end
  end
end

module Irq
  def device(dev = "")
    # get device list
    dev_list = Array.new
    unless dev.to_s.empty?
      IO.popen("lspci") do |io|  
        while line = io.gets
          dev_list << line.split()[0] if line =~ /#{dev}/
        end
      end
    dev_list
    end
  end

  def irq(dev = [])
    # get irq list
    dev_table = Hash.new
    dev.each do |id|
      dev_table[id] = Hash.new
      dev_table[id][:devnode] = File.read("/sys/bus/pci/devices/0000:#{id}/numa_node").chomp
      irqs = Array.new
      Dir.entries("/sys/bus/pci/devices/0000:#{id}").select { |e| e =~ /irq/ }.each do |type|
        if Dir.exist?("/sys/bus/pci/devices/0000:#{id}/#{type}")
          irqs = Dir.entries("/sys/bus/pci/devices/0000:#{id}/#{type}").select { |m| m =~ /[0-9]/ }
        else
          irqs = File.read("/sys/bus/pci/devices/0000:#{id}/#{type}").chomp.split()
        end

        irqs.each do |irq_id|
            irq_name = ""
            Dir.entries("/proc/irq/#{irq_id}").each { |item| irq_name = item if Dir.exist?("/proc/irq/#{irq_id}/#{item}")}
            irq_node = File.read("/proc/irq/#{irq_id}/node").chomp
            irq_type = type 
            irq_cpu = File.read("/proc/irq/#{irq_id}/smp_affinity_list").chomp
            dev_table[id][irq_id] = {
              id: irq_id,
              irqnode: irq_node ,
              cpu: irq_cpu ,
              name: irq_name ,
              type: irq_type,
            }
        end
      end
    end
    dev_table
  end

  def irq_table(dev = "")
    unless dev.to_s.empty?
      dev_table = irq device(dev)
      irqs = ""
      cpus = ""
      dev_table.each do |k,v|
        v.each do |key, value|
          unless key == :devnode
            irqs += "#{value[:id]} "
            cpus += "#{value[:cpu]} "
          end
        end
      end
      puts "#{dev_table.keys.join(",")}/#{irqs.split().join(',')}/#{cpus.split().join(',')}"
    end
  end

  def show_table(dev = "")
    unless dev.to_s.empty?
      dev_table = irq device(dev)
      table_arr = Array.new
      dev_table.each do |dev,table|
        table_list = "#{dev} #{table[:devnode]}"
        table.each { |k,v| table_arr << "#{table_list} #{v[:id]} #{v[:cpu]} #{v[:irqnode]} #{v[:type]} #{v[:name]}" if k != :devnode }
      end
      printf "%-9s %-9s %-9s %-15s %-9s %-9s %-s\n", "dev", "dev_node", "irq", "cpu", "irq_node", "type", "use"
      puts "-"*100
      table_arr.each do |t|
        t.split.each_with_index do |v,i|
          printf "%-10s", v unless i == 3 
          printf "%-16s", v if i == 3 
        end
        printf "\n"
      end
    end
  end
end
