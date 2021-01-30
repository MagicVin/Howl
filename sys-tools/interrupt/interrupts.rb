#!/usr/bin/env ruby
# xinx.e.zhang@intel.com
# Jan 29. 2021
# v1.0

class Interrupts 
  attr_reader :cpu_list
  attr_reader :irq_list
  attr_reader :inter_file

  def initialize()
    @cpu_list = ""
    @irq_list = ""
    @inter_file = "/proc/interrupts"
  end

  def set(cpu = 0 ,irq = 0)
    cpu_list = ""
    irq_list = ""

    if ( cpu.instance_of? String ) && ( irq.instance_of? String )
      cpu_list = parse(cpu)
      irq_list = parse(irq) + " "
    else
      cpu_list = cpu.to_s
      irq_list = irq.to_s + " "
    end

    @cpu_list = cpu_list
    @irq_list = irq_list.gsub(' ',': ')

  end

  def put
    puts "cpu_list: #{@cpu_list}"
    puts "irq_list: #{@irq_list}"

  end

  def parse(list = "")
    # support: 1,2,3,4-8,9-11
    ret = ""
    unless list.empty?
      list.split(',').each do |i|
        if /-/ =~ i
          Range.new(i.split('-')[0].to_i,i.split('-')[1].to_i).each { |r| ret += "#{r.to_s} " } if i.split('-').size == 2
        else
          ret += "#{i.to_s} "
        end

      end
    ret = ret.split().uniq.join(" ")
    end

    return ret
  end

  def read
    line_count = 0
    sum_value = 0
    File.open(@inter_file, 'r') do |file|
      while line = file.gets
        line_count += 1
        if line_count == 1
          title = "CPU: "
          @cpu_list.split().each { |cpu| title += "#{line.split()[cpu.to_i]} " }
          title += "Total Name"
          title.split().each { |i| printf("%-15s", i) }
          puts
        else
          str = ""
          if @irq_list.split().include? line.split()[0]
            value = 0
            str += "#{line.split()[0]} "
            @cpu_list.split().each do |cpu|
              cpu_index = cpu.to_i + 1
              value += line.split()[cpu_index].to_i
              str += "#{line.split()[cpu_index]} "
            end
            sum_value += value
            str += "#{value} "
            str += "#{line.split()[-1]}"
            "#{str}".split().each { |i| printf("%-15s", i) }
            puts 
          end
        end  
      end
      
      printf("%-15s","sum:")
      @cpu_list.split().each { |i| printf("%-15s", "---") }
      printf("%-15s\n",sum_value)
    end
  end

  def all
    all_irq = ""
    all_cpu = ""
    line_count = 0
    File.open(@inter_file,'r')  do |file|
      while line = file.gets
        line_count += 1
        line.gsub('CPU', '').split().each { |cpu| all_cpu += "#{cpu} " } if line_count == 1
        all_irq += "#{line.split()[0].gsub(':','')} " if line =~ /:/
      end 
    end
  
    set(all_cpu,all_irq)
    read

  end
end

def main 
  #part of cpu and irq
  inter = Interrupts.new
  cpu = "0-15"
  irq = "LOC"
  inter.set(cpu,irq)
  while true
    inter.read
    sleep 1
  end
  # all of cpu and irq
  #all = Interrupts.new
  #all.all
end

main
