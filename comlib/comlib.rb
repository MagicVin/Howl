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

  def sumArr(arr = [])
    unless (arr.instance_of? NilClass) || (arr.empty?)
      res = 0.0
      arr.each { |i| res += i.to_f }
      res.round(2)
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
      dev_nodes = ""
      dev_table.each do |k,v|
        irqs += "#{k}/"
        irqs += "#{v[:devnode]}/"
        dev_irqs = Array.new
        dev_cpus = Array.new
        v.each do |key, value| 
          if key != :devnode
            dev_irqs << "#{value[:id]}"
            dev_cpus << "#{value[:cpu]}"
          end
        end
        irqs += "#{dev_irqs.join(",")}/#{dev_cpus.join(",")})" unless dev_irqs.empty? || dev_cpus.empty?
      end
      # dev0/dev0_node/irqs0/cpus0)dev1/dev1_node/irqs1/cpus1
      irqs
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

module Interrupts
  include Common

  def cal_cpu( cpus = "")
    req_table = Hash.new
    unless cpus.empty?   
      cpu_list = parseStr(cpus)
      interrupts_map = Array.new

      File.open("/proc/interrupts", 'r') do |io|
        while content =  io.gets 
          interrupts_map << content.split()
        end
      end

      req_arr = Array.new
      cpu_list.split().each do |cpu|
        per_arr = Array.new
        if interrupts_map[0].index("CPU#{cpu}")
          cpu_index = interrupts_map[0].index("CPU#{cpu}")
          per_arr << interrupts_map[0][cpu_index]
          interrupts_map.each_with_index do |value, idx|
            unless idx == 0
              irq_index = cpu_index + 1
              per_arr << value[irq_index] unless value[irq_index].to_s.empty?
              per_arr << "0" if value[irq_index].to_s.empty?
            end
          end
        end
        req_arr << per_arr unless per_arr.empty?
      end
      req_arr.each { |r| req_table[r[0]] = sumArr(r[1..-1]) }
    end
    req_table
  end

  def cal_cpu_table( cpus = "")
    unless cpus.empty?   
      cpu_list = parseStr(cpus)
      interrupts_map = Array.new
      File.open("/proc/interrupts", 'r') do |io|
        while content =  io.gets 
          interrupts_map << content.split()
        end
      end
      irq_arr = Array.new
      interrupts_map.each_with_index { |v,i| irq_arr << v[0] unless i == 0 }

      req_arr = Array.new
      cpu_list.split().each do |cpu|
        per_arr = Array.new
        if interrupts_map[0].index("CPU#{cpu}")
          cpu_index = interrupts_map[0].index("CPU#{cpu}")
          per_arr << interrupts_map[0][cpu_index]
          interrupts_map.each_with_index do |value, idx|
            unless idx == 0
              irq_index = cpu_index + 1
              per_arr << value[irq_index] unless value[irq_index].to_s.empty?
              per_arr << "0" if value[irq_index].to_s.empty?
            end
          end
        end
        req_arr << per_arr unless per_arr.empty?
      end
      
      mul_tables = Array.new
      req_arr.each do |list|
        tables = Hash.new
        list.each_with_index do |v,i|
          tables["cpu"] = v if i == 0
          tables[irq_arr[i-1]] = v unless i == 0
        end
        mul_tables << tables
      end

      mul_tables[0].keys.each do |k|
      printf "#{k} "
        mul_tables.each do |l|
          printf "#{l[k]} ,"
        end
        puts
      end
    end
  end


  def loop_cpu( cpus = "")
    bef_time = Time.now.strftime("%H:%M:%S")
    bef = cal_cpu(cpus)
    sleep 1
    aft = cal_cpu(cpus)
    aft_time = Time.now.strftime("%H:%M:%S")
    bef_all = 0
    aft_all = 0
    all = 0
    printf  "%-8s %-16s %-16s %s\n" , "---", bef_time, aft_time, "rise"
    bef.keys.each do |k|
      bef_all += bef[k].to_i
      aft_all += aft[k].to_i
      all += (aft[k] - bef[k]).to_i
      printf  "%-8s %-16d %-16d %d\n" , k, bef[k].to_i, aft[k].to_i, (aft[k] - bef[k]).to_i
    end
    printf  "%-8s %-16d %-16d %d\n" , "Total", bef_all, aft_all, all
  end

  def cal_irq( irqs = "" )
    req_table = Hash.new
    unless irqs.empty?   
      irq_list = parseStr(irqs)
      interrupts_map = Array.new

      line = 0
      File.open("/proc/interrupts", 'r') do |io|
        while content =  io.gets 
          interrupts_map << content.split()
        end
      end

      cpus_len = interrupts_map[0].size
      req_arr = Array.new
      irq_list.split().each do |irq|
        per_arr = Array.new
        interrupts_map.each_with_index do |irqs, idx|
          unless idx == 0
            if "#{irq}:" == irqs[0]
              unless irqs.size < cpus_len
                name = irqs[(cpus_len+1)..-1].join("_" )
                per_arr << irqs[0]
                per_arr.concat(irqs[1..cpus_len])
                per_arr << name
              else
                per_arr.concat(irqs)
              end
            end
          end
        end
        req_arr << per_arr unless per_arr.empty?
      end
      req_arr.each { |i| req_table[i[0]] = sumArr(i[1..cpus_len]) }
    end
    req_table
  end

  def loop_irq( irqs = "" )
    bef_time = Time.now.strftime("%H:%M:%S")
    bef = cal_irq(irqs)
    sleep 1
    aft = cal_irq(irqs)
    aft_time = Time.now.strftime("%H:%M:%S")
    bef_all = 0
    aft_all = 0
    all = 0
    printf  "%-8s %-16s %-16s %s\n" , "---", bef_time, aft_time, "rise"
    bef.keys.each do |k|
      bef_all += bef[k].to_i
      aft_all += aft[k].to_i
      all += (aft[k] - bef[k]).to_i
      printf  "%-8s %-16d %-16d %d\n" , k, bef[k].to_i, aft[k].to_i, (aft[k] - bef[k]).to_i
    end
    printf  "%-8s %-16d %-16d %d\n" , "Total", bef_all, aft_all, all
  end

  def cal_both( cpus = "", irqs = "")
    req_table = Array.new
    unless cpus.empty? && irqs.empty?
      cpu_list = parseStr(cpus).split()
      irq_list = parseStr(irqs).split()
      interrupts_map = Array.new
      req_map = Array.new

      File.open("/proc/interrupts", 'r') do |io|
        while content =  io.gets
          interrupts_map << content.split()
        end
      end
     
      cpu_idx = Array.new
      cpu_list.map! { |i| "CPU#{i}" }
      req_table[0] = Array.new
      cpu_list.each do |c| 
        if interrupts_map[0].include?(c)
          cpu_idx << interrupts_map[0].index(c)
          req_table[0] << c
        end
      end

      irq_list.each do |i|
        interrupts_map.each do |list|
          if list[0] == "#{i}:"
            value_arr = Array.new
            value_arr << list[0]
            cpu_idx.each { |c| value_arr << list[c+1] }
            req_table << value_arr
          end
        end
      end

      req_table.each { |i| p i }
    end
  end

  def cal_cpuside(table = {})
    sum_table = Hash.new 
    unless table.empty?
      table[0].each do |c|
        cidx = table[0].index(c)
        sum = 0.0
        table[1..-1].each { |i| sum += i[cidx+1] }
        sum_table[c] = sum.to_i
      end
    end
    sum_tabl
  end
end
