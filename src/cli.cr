require "./crapi"

module CrAPI::CLI
  extend self
  def open(path)
    File.open(path) do |file|
      CrAPI.from_json(file)
    end
  end

  def display_result(query, result : Nil)
    puts "*** No Result for #{query.dump} ***"
  end

  def display_result(query, result : CrAPI::Macro)
    puts result.name
  end

  def display_result(query, result : CrAPI::Method)
    puts result.name
  end

  def display_result(query, result : CrAPI::Type)
    puts result.name
  end

  def display_methods(crapi : CrAPI, result : CrAPI::Type)
    puts "#{result.name}: "
    result.instance_methods.each do |method|
      print "abstract " if method.abstract
      print "#{method.name}#{method.args_string}"
      puts
    end

    result.ancestors.each do |ancestor|
      display_methods(crapi, crapi.type(ancestor))
    end
  end

  def display_methods(crapi : CrAPI, type)
    raise "Not a type: #{type} (#{type.class})."
  end
end

crapi = nil
{"docs/index.json", "index.json"}.each do |path|
  if File.exists?(path)
    crapi = CrAPI::CLI.open(path)
  end
end
crapi || raise "Couldn't find API file."

options = ARGV.dup
command = options.shift
puts "command #{command}"
case command
when "query"
  query = options[0]? || abort "No query given"

  #uses(crapi, "String", crapi.type("ENV"))

  uses(crapi, query, crapi.program)
when "search"
  query = options[0]? || abort "No query given"
  result = crapi.lookup(query)

  CrAPI::CLI.display_result(query, result)
when "show"
  query = options[0]? || abort "No query given"
  result = crapi.lookup(query)

  result.to_json(STDOUT)
when "show-methods"
  query = options[0]? || abort "No query given"
  result = crapi.lookup(query)

  CrAPI::CLI.display_methods(crapi, result)
else
  abort "Unknown command #{command}"
end

def print_subclasses
  exception = api.type("Exception")

  api.print_subclass_tree(STDOUT, exception)
end

def uses(crapi, search_type, parent)
  search_type = search_type.to_s
  return_type_uses = [] of {CrAPI::Type, CrAPI::Method}
  argument_uses = [] of {CrAPI::Type, CrAPI::Method, CrAPI::Argument}


  crapi.each_type(parent) do |type|
    method_handler = ->(method : CrAPI::Method) do
      if method.def.return_type == search_type
        return_type_uses << {type, method}
      end
      method.args.each do |arg|
        if arg.restriction =~ /\b#{type}/
          argument_uses << {type, method, arg}
        end
      end
    end

    type.instance_methods.each &method_handler
    type.class_methods.each &method_handler
  end

  {return_type_uses, argument_uses}
end
