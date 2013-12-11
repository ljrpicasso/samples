# ruby_console.rb -- console i/o without external gems

def get_yn( prompt="Yes or No? " )
  print prompt
  while true
    case $stdin.getc.downcase
    when 'y' then return true
    when 'n' then return false
    end
  end
end

def get_string( prompt, required=true, help='no help provided... sorry!' )
  input = ''
  while input == ''
    print prompt
    input = $stdin.gets.chomp
    if input == '?'
      puts help
      input = ''
    else
      if !required 
        break
      end
    end
  end
  input
end

def get_lines( prompt, help='no help provided... sorry!' )
  input = ''
  line = '.'
  puts prompt
  while line != ''
    print "> "
    line = $stdin.gets.chomp
    if line == '?'
      puts help
      puts "\nThis is what you've entered so far:"
      puts input
      puts "\nNow, please continue:"
    else
      input = "#{input}#{line}\n" if line != ''
    end
  end
  input
end

