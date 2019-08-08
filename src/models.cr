require "json"

class CrAPI
  class RelativeLocation
    JSON.mapping({
      filename: String,
      line_number: Int32,
      url: String
    })
  end

  class Type
    JSON.mapping({
      html_id: String,
      path: String,
      kind: String,
      full_name: String,
      name: String,
      abstract: Bool,
      superclass: TypeRef?,
      ancestors: Array(TypeRef),
      locations: Array(RelativeLocation),
      repository_name: String,
      program: Bool,
      enum: Bool,
      alias: Bool,
      aliased: String,
      const: Bool,
      constants: Array(Constant),
      included_modules: Array(TypeRef),
      extended_modules: Array(TypeRef),
      subclasses: Array(TypeRef),
      including_types: Array(TypeRef),
      namespace: TypeRef?,
      doc: String?,
      summary: String?,
      class_methods: Array(Method),
      constructors: Array(Method),
      instance_methods: Array(Method),
      macros: Array(Macro),
      types: Array(Type),
    })

    def type(name : String) : Type
      types.find { |type| type.name == name } || raise "Not found: #{name}"
    end

    def instance_method?(name : String) : Method?
      instance_methods.find { |method| method.name == name }
    end

    def class_method?(name : String) : Method?
      class_methods.find { |method| method.name == name }
    end

    def constructor?(name : String) : Method?
      constructors.find { |method| method.name == name }
    end

    def macro?(name : String) : Macro?
      macros.find { |macr| macr.name == name }
    end
  end

  class TypeRef
    JSON.mapping({
      html_id: String?,
      kind: String,
      full_name: String,
      name: String
    })

    def to_s(io : IO)
      io << kind << ' ' << full_name
    end
  end

  class Constant
    JSON.mapping({
      name: String,
      value: String,
      doc: String?,
      summary: String?
    })
  end

  class Macro
    JSON.mapping({
      id: String,
      html_id: String,
      name: String,
      doc: String?,
      summary: String?,
      abstract: Bool,
      args: Array(Argument),
      args_string: String,
      source_link: String?,
      def: CrystalMacro,
    })
  end

  class Method
    JSON.mapping({
      id: String,
      html_id: String,
      name: String,
      doc: String?,
      summary: String?,
      abstract: Bool,
      args: Array(Argument),
      args_string: String,
      source_link: String?,
      def: CrystalDef,
    })

    def return_type
      self.def.return_type
    end
  end

  class Argument
    JSON.mapping({
      name: String,
      doc: String?,
      default_value: String,
      external_name: String,
      restriction: String
    })
  end

  class CrystalDef
    JSON.mapping({
      name: String,
      args: Array(Argument),
      double_splat: Argument?,
      splat_index: Int32?,
      yields: Int32?,
      block_arg: Argument?,
      return_type: String,
      visibility: String,
      body: String
    })
  end

  class CrystalMacro
    JSON.mapping({
      args: Array(Argument),
      double_splat: Argument?,
      splat_index: Int32?,
      block_arg: Argument?,
      visibility: String,
      body: String
    })
  end
end
