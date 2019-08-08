require "./models"

class CrAPI
  JSON.mapping({
    repository_name: String,
    body: String,
    program: Type
  })

  getter registry : Hash(String, Type) do
    Hash(String, Type).new.tap do |registry|
      each_type do |type|
        registry[type.full_name] = type
      end
    end
  end

  def lookup(query)
    type, separator, identifier = query.partition(/[#.]/)
    case separator
    when "#"
      type(type).instance_method?(identifier)
    when "."
      type = type(type)
      type.class_method?(identifier) || type.macro?(identifier)
    else
      type(type)
    end
  end

  def type(ref : TypeRef) : Type
    type ref.full_name
  end

  def type(name : String) : Type
    registry[name]
  end

  def each_type(type = program, &block : Type ->)
    block.call(type)
    type.types.each do |subtype|
      block.call(subtype)
      each_type(subtype, &block)
    end
  end

  def each_subclass(type, &block : TypeRef ->)
    type.subclasses.each do |subclass|
      block.call(subclass)
      each_subclass(type(subclass), &block)
    end
  end

  def all_subclasses(type : Type)
    subclasses = [] of TypeRef
    each_subclass(type) do |subclass|
      subclasses << subclass
    end
    subclasses
  end

  def print_subclass_tree(io, type, indent = 0)
    io << "  " * indent
    io << "* " << type.full_name
    io << "\n"
    type.instance_methods.each do |method|
      next unless method.args.empty?
      io << "  " * indent
      io << "  - " << method.name << " : " << method.def.return_type
      io << "\n"
    end
    type.subclasses.each do |subclass|
      print_subclass_tree(io, type(subclass), indent + 1)
    end
  end
end
