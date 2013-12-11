# generate.rb
# contains methods parse_long_text and generate_command.

def parse_long_text(str)
  (str.split("\n").collect do |line|
   if line == "."
      "\n#"
    else
      " #{line}\n#"
    end
  end).join
end

def generate_command( command, options )
  new_command_name = command.downcase
  puts "\n>>> Generating command sub-#{new_command_name}..." 

  @usage = get_string("Usage: ", false, 
                     "Enter the usage for your new command. For instance,\n" +
                     "      sub mycmd <params>")

  @summary = get_string("Summary: ", false, 
                       "Enter the summary for your new command. For instance,\n" +
                       "      mycmd is used to eat smurfs.")

  @help = get_lines("Help (enter a blank line to end): ", 
                   "Enter the help text for your new command.\n" +
                   "Use a period to insert a blank line, and a blank line to exit.")

  @root_dir = "#{ENV['_SUB_ROOT']}"
  @share_dir = "#{@root_dir}/share"
  
  @new_command_file = "#{@root_dir}/libexec/sub-#{new_command_name}"

  puts "> Generating #{@new_command_file}..." if options[:verbose]
  puts "> using templates from #{@share_dir}" if options[:verbose]

  template = options[:ruby] ? 
    IO.read( "#{@share_dir}/sub/ruby_template.erb" ) : 
    IO.read( "#{@share_dir}/sub/bash_template.erb" )

  renderer = ERB.new(template)
  output = renderer.result()

  if File.exists?(@new_command_file)
    puts "*** The command file already exists. Should I replace"
    if (get_yn("*** it with the new one? [y/n] "))
      puts ">> Deleting #{@new_command_file}..." if options[:verbose]
      File.delete(@new_command_file)
    else
      puts "** File exists, you don't want to overwrite, so I'm stopping." if options[:verbose]
      exit 1
    end
  end

  puts "> Writing template with new values into #{@new_command_file}..." if options[:verbose]
  IO.write( @new_command_file, output )
  puts "> Making the new command executable..." if options[:verbose]
  FileUtils.chmod "a+x", @new_command_file
  puts "> ... complete." 

end
