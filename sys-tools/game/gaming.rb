#!/usr/bin/env ruby

class Gaming
  BIRTHDAY = "DEC 13 2020"
  VERSION = 1.0
  attr_accessor :act_table
  attr_accessor :games
  attr_accessor :tasks
  attr_accessor :loops
  attr_accessor :pattern
  attr_accessor :account
  attr_accessor :step
  attr_reader :guide_msg
  attr_accessor :nickname
  attr_reader :randmap

  def initialize(act_table = "")
    @loops = []
    @account = []
    @pattern = :seq
    @act_table = []
    @act_table = act_table.map { |i| i } if act_table.is_a? Array
    @tasks = {}
    @games = ["kog"]
    @nickname = ""
    @randmap = []
    (47..57).collect { |i| @randmap << i } #0-9
    (65..90).collect { |i| @randmap << i } #A-Z
    (97..122).collect { |i| @randmap << i } #a-z

    @guide_msg = <<-EOB
usage:
  ./gaming.rb [step] [list] [pattern]

  instances are 0-10, thread pattern is seq, game step is account
  ./gaming.rb account 0-10 seq

EOB

    items_get

  end

  def seq_proc(num)
    begin
      puts "android#{num} run"
      cmds(num)
    rescue => ex
      puts "cmds error"
      puts ex.message
    end
  end

  def mul_proc(num)
    begin
      task = Thread.new { cmds(num) }
      @tasks["android#{num}"] = task
      puts "android#{num} #{task} #{task.status}"
      sleep 1
    rescue => ex
      puts "cmds error"
      puts ex.message
    end
  end
  
  def spawn_cmds(name)
    Process.exit if @act_table.empty?
    puts "#{name} is going ..." 
    @act_table.each do |act|
      str = as("#{act} #{name}")
      model = "docker exec #{name} sh -c #{str}"
      pid = spawn(model)
      @tasks << pid
      sleep 0.5
    end
    @tasks.size.times { |idx| Process.wait @tasks[idx] }
    @tasks.size.times { |idx| @tasks.shift }
  end

  def cmds(num)
    Process.exit if @act_table.empty?
    pid = Process.fork do
      @act_table.each do |act|
        name = "android#{num}"
        if /account/ =~ act
          if @account[num]
            act.sub!('account',@account[num])
          else
            puts "No more accounts are available for #{name}"
            break
          end
        end
         
        if /nickname/ =~ act
          @nickname << "a#{num}"       
          act.sub!('nickname',@nickname)
        end

        repeat = 1
        if /move/ =~ act 
          repeat = act.split()[1].split(/>/)[-1].to_i
          if repeat <= 0 
            puts "repeat: #{repeat} number must be  >= 1"
            Process.exit
          else 
            act.sub!(/ move>[0-9]+/,'')
          end
        end

        str = as(act)
        model = "docker exec #{name} sh -c #{str}"
        repeat.times do 
          #puts model
          IO.popen(model) { puts model }
          #IO.popen(model,:err => [:child, :out]) do |io|
          #  while line = io.gets
          #    puts line 
          #  end
          #end
        end

      end
    end
    Process.wait pid
  end

  def games_run
    game_steps if @act_table.empty?
    @loops.each do |i|
      seq_proc i if @pattern == :seq 
      mul_proc i if @pattern == :mul
    end

    @tasks.values { |task| task.join } if ! @tasks.empty?
    @tasks.each { |k,v| puts "#{k}: #{v.status} finished"} if ! @tasks.empty?
    sleep 1
    puts 'games done'

  end

  def game_steps
    oldaccount_set =[
      "input tap 100 100" , #tap screen
      "input tap 1230 55" , #skip video
      "input tap 1230 55" , 
      "sleep 5" ,
      "input tap 1238 35" , #disconnect account
      "sleep 2" ,
      "input tap 888 600" , #click 'play with qq friend'
      "sleep 10" ,
      "input tap 80 470" , #click switch account button
      "sleep 2" ,
      "input tap 80 40" ,
      "sleep 2" ,
      "input tap 170 170" , #click input qq account
      "input tap 1155 177" , #clean old account
      "input text account" , #input account
      "input tap 170 270" , #click input passwd
      "input tap 1155 260" , #clean old passwd
      "input tap 483 610" , #input c
      "input tap 1088 522" , #input l
      "input tap 1026 442" , #input o
      "input tap 785 440" , #input u
      "input tap 362 525" , #input d 
      "input tap 90 688" , #input ?123 
      "input tap 1145 442" , #input 0 
      "input tap 1145 442" , #input 0 
      "input tap 1145 442" , #input 0 
      "input tap 55 440" , #input 1
      "input tap 170 370" , #click login button
      "sleep 10" ,
      #"input tap 700 550" , #click agree button
      #"sleep 1" ,
      #"input tap 666 500" ,
      "input tap 800 555" ,
      "sleep 1",
      "input tap 800 555" ,
    ]

    account_set = [
      "input tap 700 480" , #privacy guide
      "sleep 1",
      "input tap 50 30" , #return
      "sleep 1" ,
      "input tap 100 100" , #type the screen
      "sleep 1" ,
      "input tap 1230 45" , #skip the cartoon
      "sleep 1",
      "input tap 1230 45" , #logout
      "sleep 2" ,
      "input tap 800 580" , #play with qq friends
      "sleep 20" ,
      "input tap 603 465" , #switch account
      "sleep 2" ,
      "input tap 1153 175" , #type the account box
      "sleep 2" ,
      "input tap 1153 175" , #clean the old account
      "sleep 1",
      "input text account" , #input the account
      "sleep 1" ,
      "input tap 1153 260" , #type the passwd box
      "sleep 1" ,
      "input tap 1153 260" , #clean the old passwd 
      "sleep 1" ,
      "input tap 483 610" , #input c
      "input tap 1088 522" , #input l
      "input tap 1026 442" , #input o
      "input tap 785 440" , #input u
      "input tap 362 525" , #input d
      "input tap 90 688" , #input ?123
      "input tap 1145 442" , #input 0
      "input tap 1145 442" , #input 0
      "input tap 1145 442" , #input 0
      "input tap 55 440" , #input 1
      "input tap 1000 370" , #click login button
      "sleep 15" ,
      "input tap 640 490" , #confirm name info
      "sleep 1",
      "input tap 50 30" , #return
      "sleep 2",
      "input tap 900 520" , #confirm the privacy policy
      #"sleep 1",
      #"input tap 50 30" , #return
    ]

    open_set = [
      "am start -S -W com.tencent.tmgp.sgame/com.tencent.tmgp.sgame.SGameActivity" ,
    ]

    start_set = [
      "input tap 640 560" , #click button to start game 
      "sleep 30" ,
    ]

    role_set = [
      "input tap 640 560" , #click button to start game 
      "sleep 4" ,
      "input tap 900 350" , #click button to input nickname
      "input tap 1120 606" , #clean the old nickname
      "input text nickname" , #input nickname
      "input tap 1150 290" , #click ok to confirm the nickname
      "input tap 770 440" , #click the create role button
      "sleep 30" ,
      "input tap 666 500" ,
      "sleep 1" ,
      "input tap 800 555" ,
      "sleep 5",
    ]

    first_set = [
      "input tap 100 100" , #tap the screen
      "sleep 30" ,
      "input tap 100 100" , #tap the screen
      "sleep 1" ,
      "input tap 150 280", #buy the shoes
      "sleep 1" ,
      "input swipe 180 567 270 446 2000" , 
      "sleep 2" ,
      "input move>2 tap 1155 622", #click attack button
      "sleep 3" ,
      "input tap 881 561" , # upgrade q
      "sleep 2" ,
      "input tap 950 630" , #click q
      "sleep 2" ,
      "input tap 1155 622", #click attack button
      "sleep 4" ,
      "input tap 958 427" , #upgrate w
      "sleep 2" ,
      "input tap 1030 500" , #click w
      "sleep 4" ,
      "input tap 150 280", #buy thing
      "sleep 3" ,
      "input tap 958 427" , #upgrate w
      "input swipe 180 567 331 468 3000" , 
      "sleep 2" ,
      "input tap 1030 500" ,
      "sleep 5" ,
      "input tap 1088 345" ,#upgrade r
      "sleep 5" ,
      "input tap 100 100" , #tap the screen
      "sleep 1" ,
      "input tap 950 630" , #click q
      "input tap 1155 622", #click attack button
      "input tap 1030 500" , #click w
      "sleep 4" ,
      "input tap 1165 428" , #click r
      "sleep 1" ,
      "input tap 950 630" , #click q
      "sleep 4" ,
      "input tap 46 304" , #visit the shop
      "sleep 1" ,
      "input tap 100 100" , #tap the screen
      "sleep 1" ,
      "input tap 1190 69" ,
      "sleep 1" ,
      "input tap 830 650", #click healing button
      "sleep 5" ,
      "input tap 100 100" , #tap the screen
      "sleep 1" ,
      "input tap 730 650" , # click go home button
      "sleep 8" , 
      "input tap 100 100" , #tap the screen
      "sleep 15" ,
      "input tap 100 100" , #tap the screen
      "sleep 230", 
      "input tap 666 666",
      "sleep 5" ,
      "input tap 666 666",
      "sleep 2" ,
      "input tap 100 100" , #tap the screen
      "sleep 3" ,
      "input tap 730 420" , #go to the next training
    ]

    second_set = [
      "input tap 730 420" , #go to the next training
      "sleep 30" ,
      "input tap 100 100" , #tap the screen
      "sleep 10" ,
      "input tap 100 100" , #tap the screen
      "sleep 3" ,
      "input tap 150 280", #buy the shoes
      "sleep 3" ,
      "input tap 881 561" , # upgrade q
      "sleep 2" ,
      "input swipe 180 567 300 470 3000" ,
      "input swipe 180 567 227 450 5000" ,
      "input swipe 180 567 220 500 9700" ,
      "sleep 5",
      "input tap 100 100" , #tap the screen
      "sleep 5" ,
      "input tap 1244 94" ,
      "sleep 60",
      "input tap 1155 622", #click attack button
      "input tap 881 561" , # upgrade q
      "input tap 958 427" , #upgrate w
      "input tap 1088 345" ,#upgrade r
      "sleep 2" ,
      "input swipe 180 567 220 500 9000" ,
      "input tap 100 100" , #tap the screen
      "sleep 5" ,
      "input tap 1244 94" ,
      "input tap 950 630" , #click q
      "input tap 1155 622", #click attack button
      "input tap 1030 500" , #click w
      "input tap 1155 622", #click attack button
      "input move>5 swipe 180 567 220 500 9000" ,
      "input tap 100 100" , #tap the screen
      "sleep 5" ,
      "input tap 1244 94" ,
      "input tap 881 561" , # upgrade q
      "input tap 958 427" , #upgrate w
      "input tap 1088 345" ,#upgrade r
      "input tap 950 630" , #click q
      "input tap 1155 622", #click attack button
      "input tap 1030 500" , #click w
      "input tap 1165 428" , #click r
      "input tap 1155 622", #click attack button
      "input tap 881 561" , # upgrade q
      "input tap 958 427" , #upgrate w
      "input tap 1088 345" ,#upgrade r
      "input tap 950 630" , #click q
      "input tap 1155 622", #click attack button
      "input tap 1030 500" , #click w
      "input tap 1165 428" , #click r
      "input tap 1155 622", #click attack button
      "sleep 10" ,
      "input move>5 swipe 180 567 220 500 9000" ,
      "input tap 881 561" , # upgrade q
      "input tap 958 427" , #upgrate w
      "input tap 1088 345" ,#upgrade r
      "input tap 950 630" , #click q
      "input tap 1155 622", #click attack button
      "input tap 1030 500" , #click w
      "input tap 1165 428" , #click r
      "input tap 1155 622", #click attack button
      "sleep 10" ,
      "input move>5 swipe 180 567 220 500 9000" ,
      "input tap 881 561" , # upgrade q
      "input tap 958 427" , #upgrate w
      "input tap 1088 345" ,#upgrade r
      "input tap 950 630" , #click q
      "input tap 1155 622", #click attack button
      "input tap 1030 500" , #click w
      "input tap 1165 428" , #click r
      "input tap 1155 622", #click attack button
      "sleep 10" ,
      "input tap 640 655" ,
      "sleep 2",
      "input tap 100 100" , #tap the screen
    ]

    third_set = [
      "input tap 500 560" ,
      "sleep 1" ,
      "input tap 200 350" ,
      "sleep 1",
      "input tap 200 350" ,
      "sleep 10",
      "input tap 630 610" ,
      "sleep 3",
      "input tap 655 640" ,
      "sleep 3",
      "input tap 720 600", # start 5v5
      "sleep 3" ,
      #"input tap 640 610" , # click confirmation for ready
    ]

    rand_role = [
      "input tap 60 130" ,
      "input tap 175 130" ,
      "input tap 60 270" ,
      "input tap 175 270" ,
      "input tap 60 390" ,
      "input tap 175 390" ,
      "input tap 60 540" ,
      "input tap 175 540" ,
    ]
  

   20.times do 
     third_set  << "input tap 640 610"
     third_set << "sleep 10"
     third_set << rand_role[rand(8)]
     third_set << "sleep 5"
     third_set << "input tap 1200 690"
     third_set << "sleep 5"
   end

   third_share = [
    "sleep 600" ,
    "input tap 666 666" ,
    "sleep 3" ,
    "input tap 666 666" ,
    "sleep 3" ,
    "input tap 555 666" ,
    "sleep 900" ,
    "input tap 640 673" , #battle done, click to continue
    "sleep 2" ,
    "input tap 640 673" , #click to continue
    "sleep 5" ,
    "input tap 555 643" , #go back to the hall
   ]

   third_set = ( third_set + third_share )


   fourth_set = [
    "input tap 520 550" , #click to battle
    "sleep 3" ,
    "input tap 1100 400" , #click training mode
    "sleep 2" ,
    "input tap 260 335" , #junior class
    "sleep 2" ,
    "input tap 780 230" ,
    "sleep 40", 
    "input tap 100 100" ,
    "sleep 30" ,
    "input swipe 1024 510 1100 416" ,
    "sleep 8" ,
    "input swipe 1024 510 1100 416" ,
    "input swipe 1024 510 1100 470" ,
    "input swipe 1024 510 1100 500" ,
    "input swipe 1024 510 1100 500" ,
    "input swipe 1024 510 1100 500" ,
    "input swipe 1024 510 1100 500" ,
    "sleep 10" ,
    "input swipe 1024 510 1140 118 2000" ,
    "sleep 10" ,
    #"input swipe 1170 426 1250 345" ,
    "input tap 1170 426" ,
    "sleep 10" ,
    "input tap 1200 40" ,
    "sleep 30" ,
    "input tap 666 666" ,
    "sleep 15" ,
    "input tap 666 666" ,
    "input tap 666 666" ,
    "sleep 5" ,
    "input tap 640 590" ,
    "input tap 640 590" ,
    "input tap 640 590" ,
    "sleep 15" ,
    "input tap 1060 100" ,
    "input tap 1060 100" ,
    "input tap 1060 100" ,
    "sleep 5" ,
    "input tap 666 666" ,
    "sleep 2" ,
    "input tap 640 590" ,
    "sleep 20" ,
    "input tap 1060 100" ,
    "sleep 20" ,
    "input tap 1000 610" , #click accept
    "sleep 5" ,
    "input tap 640 590" , #click confirm
    "sleep 10" ,
    "input tap 640 590" , #click confirm
   
   ]

   final_set = [
    "input tap 666 666" ,
    "sleep 2" ,
    "input tap 640 590" ,
    "sleep 20" ,
    "input tap 1060 100" ,
    "sleep 20" ,
    "input tap 1000 610" , #click accept
    "sleep 5" ,
    "input tap 640 590" , #click confirm
   ]

    case @step
    when :account 
      @act_table = ( @act_table + account_set )
    when :start
      @act_table = ( @act_table + start_set )
    when :open
       @act_table = ( @act_table + open_set )
    when :role
      @act_table = ( @act_table + role_set )
      nname = ""
      4.times { nname << rand(0-9).to_s }
      2.times { nname << @randmap[rand(@randmap.size)].chr }
      @nickname = nname
    when :first
      @act_table = ( @act_table + first_set )
    when :second
      @act_table = ( @act_table + second_set )
    when :third
      @act_table = ( @act_table + third_set )
    when :fourth
      @act_table = ( @act_table + fourth_set )
    when :final
      @act_table = ( @act_table + final_set )
    when :go0
      @act_table = ( @act_table + third_set + fourth_set )
    when :stage
      #@act_table = ( @act_table + role_set + first_set + second_set + third_set + fourth_set )
      #@act_table = ( @act_table + first_set + second_set + third_set + fourth_set )
      #@act_table = ( @act_table + second_set + third_set + fourth_set )
      #@act_table = ( @act_table + third_set + fourth_set )
      @act_table = ( @act_table + role_set + first_set + second_set + third_set + fourth_set )
      nname = ""
      4.times { nname << rand(0-9).to_s }
      2.times { nname << @randmap[rand(@randmap.size)].chr }
      @nickname = nname
    when :guide
      @act_table = ( @act_table + account_set + start_set + role_set + first_set + second_set + third_set + fourth_set )
      nname = ""
      4.times { nname << rand(0-9).to_s }
      2.times { nname << @randmap[rand(@randmap.size)].chr }
      @nickname = nname
    else
      puts @guide_msg
      Process.exit
    end

  end
  
  def game_conf(conf)
    Process.exit if ! File.exist? conf
    File.open(conf, 'r') do |file|
      while line = file.gets
        @account << line.chomp.split(' ')[0]
      end
    end
  end

  def as(str)
    return "\'#{str}\'"
  end

  def gtest
    @act_table = [
      "echo `date +%s` a" ,
      "sleep 1" ,
      "echo `date +%s` b" ,
      "echo account" ,
    ]
  end

  def items_get
    if ARGV.empty?
      puts @guide_msg
      Process.exit
    end

    modes = {
      "seq" => :seq ,
      "mul" => :mul ,
    }

    steps = {
      "account" => :account ,
      "start" => :start ,
      "role" => :role ,
      "first" => :first ,
      "second" => :second ,
      "third" => :third ,
      "fourth" => :fourth ,
      "final" => :final ,
      "stop" => :stop ,
      "open" => :open ,
      "stage" => :stage ,
      "go0" => :go0 ,
      "guide" => :guide ,

    }

    modes.map { |k,v| @pattern = v if ARGV.include? k }
    steps.map { |k,v| @step = v if ARGV.include? k }
    
    ARGV.each do |i|
      if /^[0-9]*$/ =~ i
        @loops << i.to_i if ! @loops.include? i
      elsif /^[0-9]+\-[1-9]+$/ =~ i
        sarr = (eval i.sub('-','..')).collect { |i| i }
        @loops = (sarr | @loops)
      end
    end
    #@loops.uniq!.sort!
    @loops.sort!.uniq!
    puts "loops: #{@loops}"
    puts "pattern: #{@pattern}"
    puts "step: #{@step}"
    
    if ! @step
      puts "step is nil , can't start"
      puts @guide_msg
      Process.exit 
    end

  end
end

game = Gaming.new()
game.game_conf('/data/aic/vm1-account.txt')
game.games_run
#puts "#{game.account.size} #{game.account}"
