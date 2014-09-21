module Music
module Performance
class TimeScore
  attr_reader :parts, :program
  
  def initialize parts, program
    @parts = parts
    @program = program
  end
end

end
end