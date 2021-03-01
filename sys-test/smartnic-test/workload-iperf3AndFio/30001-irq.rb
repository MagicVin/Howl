#!/usr/bin/env ruby
# xinx.e.zhang@intel.com
# Feb 1, 2021
# v1.1

require 'optparse'

class Get_irq
  attr_reader :irq_list
  attr_accessor :dev_list
  attr_reader :irq_tables
  attr_reader :options

  def initialize
    @irq_list = Array.new
    @dev_list =  Array.new
    @irq_tables = Array.new
    opts
  end

  def opts
    @options = {}
    OptionParser.new do |opt|
      opt.banner = "Usage: ./#{File.basename(__FILE__)} [-d [dev] or -r [regx]] -t [irq_type]"
      opt.on("-r", "--device_regx DEVICE_REGX", "set device type") { |v| @options[:regx] = v }
      opt.on("-t", "--irq_type IRQ_TYPE", "set irq type(should be 'irq' or 'msi_irqs')") { |v| @options[:type] = v }
    end.parse!
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

  def get_dev
    @dev_list.clear
    unless ( @options[:regx].instance_of? NilClass ) || ( @options[:regx].empty? )
      IO.popen("lspci") do |io|
        while line = io.gets
          @dev_list << line.split()[0] if line =~ /#{@options[:regx]}/
        end
      end
    end
  end

  def irq_table(dev,irq)
    unless ( dev.instance_of? NilClass ) && ( irq.instance_of? NilClass )
      irq = irq.split().join(',')
      all_cpus = ""
      irq.split(',').each do |i|
        smp_list="/proc/irq/#{i}/smp_affinity_list"
        list = File.read(smp_list).chomp if File.readable? smp_list
        all_cpus += "#{list} "
      end
      # dev:irq:cpu
      return "(#{dev}/#{irq}/#{all_cpus.split().join(',')})"
    else
      return -1
    end
  end

  def get_irq
    irq_def = %w(irq msi_irqs)
    irq_total = ""
    if irq_def.include? @options[:type]
      dev_dir = "/sys/bus/pci/devices/0000"
      @dev_list.each do |dev|
        irq_file = "#{dev_dir}:#{dev}/#{@options[:type]}" 
        irq = File.read(irq_file) if File.file? irq_file
        irq = Dir.entries(irq_file).join(" ").gsub(/\./,"") if File.directory? irq_file
        @irq_tables << irq_table(dev,irq) unless irq_table(dev,irq) == -1
        irq_total += "#{irq} "
      end
      irq_total.split().each { |i| @irq_list << i }
    else
      puts "type(#{@options[:type]} does not support!)"
      return -1
    end
  end

  def res_read(str)
    dev=str.split()[0]
    irq=str.split()[1]
    table=str.split()[2].gsub('table(dev/irq/cpu)-','')
    puts "dev: #{dev}"
    puts "irq: #{irq}"
    puts "table:"
    table.split(';').each do |i|
      #puts i
      i.gsub(/[( ) \/]/,' ').split().each_with_index do |j,n|
        printf("dev ") if n == 0
        printf("irq ") if n == 1
        printf("cpu ") if n == 2
        j.split(',').each do |k|
          printf("%-8s",k) 
        end
        puts
      end
    end
  end

  def pin_irq(str,cpu)
    table=str.split()[2].gsub('table(dev/irq/cpu)-','')
    cpu = parse(cpu)
    cpu_range = cpu.split(' ')
    table_range = table.split(';')
    count=0
    cpu_range.each do
      table_range[count].gsub(/[( ) \/]/,' ').split().each_with_index do |j,n|
        if n == 1
          j.split(',').each do |k|
            file = "/proc/irq/#{k}/smp_affinity_list"
            File.open(file,'w') { |io| io.puts "#{cpu_range[count]}" }
          end
        end
      end
      count += 1
    end
  end

end

def main
  irq = Get_irq.new
  irq.get_dev
  irq.get_irq
  res = "dev:#{irq.dev_list.join(",")} irq:#{irq.irq_list.join(",")} table(dev/irq/cpu)-#{irq.irq_tables.join(";")}"
  #irq.res_read(res)
  #irq.pin_irq(res,'0-3')
  puts res
end

main
