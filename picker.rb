class Picker

  attr_accessor :name, :text

  def initialize( name, text )
    @name = name
    @text = text
  end

  def to_doc
    { "name" => @name, "text" => @text }
  end
end
