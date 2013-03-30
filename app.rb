# encoding: utf-8

configure do
  LOGGER = Logger.new('sinatra.log')
  DB = Sequel.connect(:adapter=>'mysql2', :host=>'db_host_ip', :database=>'db_name', :user=>'db_user', :password=>'db_password')
  enable :logging
end

helpers do
  include Rack::Utils

  def logger
    LOGGER
  end
end

get '/' do
  #logger.debug "Handling '/' request."

  number = "#{params[:number].to_s}"
  number.sub!(/^0+/,"")
  number.sub!(/^371/,"") 
  result = false
  unless result
    result = params[:number] if number.length < 8
  end
  unless result
    DB.fetch("SELECT * FROM accounts WHERE phones_string LIKE '%#{number}%'") do |row|
      result = "#{row[:name]}"
      result = ru_lv_translit(result)
    end
  end
  unless result
    my_have_phones = ["contacts","leads","users"]
    my_have_phones.each do |table|
      DB.fetch("SELECT * FROM #{table} WHERE phones_string LIKE '%#{number}%'") do |row|
        result = "#{row[:last_name]} #{row[:first_name]}"
        result = ru_lv_translit(result)
      end
      break if result
    end
  end
  if result
    "#{result}"
  else
    #logger.debug "5555 #{result}"
    "#{params[:number]}"
  end
end

def latvian_translit(text)
  translited = text.gsub(/[āčēģīķļņŗšūžōĀČĒĢĪĶĻŅŖŠŪŽŌ]/,
   'ā' => 'aa', 'č' => 'ch', 'ē' => 'ee', 'ģ' => 'gj', 'ī' => 'ii', 'ķ' => 'kj', 'ļ' => 'lj', 'ņ' => 'nj', 'ŗ' => 'rj', 'š' => 'sh','ū' => 'uu', 'ž' => 'zh', 'ō' => 'oo', 'Ā' => 'AA', 'Č' => 'CH', 'Ē' => 'EE', 'Ģ' => 'GJ', 'Ī' => 'II', 'Ķ' => 'KJ', 'Ļ' => 'LJ', 'Ņ' => 'NJ', 'Ŗ' => 'RJ', 'Š' => 'SH','Ū' => 'UU', 'Ž' => 'ZH', 'Ō' => 'OO')
  return translited
end

def ru_lv_translit(text)
  translited = Russian.translit(text)
  translited = latvian_translit(translited)
  return translited
end
