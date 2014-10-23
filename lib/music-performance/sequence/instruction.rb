module Music
module Performance

# Contains classes used by performer to specify performance
# instructions and associated information. A different class
# for each instruction.
class Instruction
  attr_reader :offset
  
  def initialize offset
    @offset = offset
  end

  def clone
    Marshal.load(Marshal.dump(self))
  end
  
  def shift_offset amt
    self.clone.shift_offset! amt
  end
  
  def shift_offset! amt
    @offset += amt
    return self
  end
  
  class Start < Instruction
    attr_reader :pitch, :attack_loudness, :attack_duration
    def initialize offset, pitch, attack_loudness, attack_duration
      @pitch = pitch
      @attack_loudness = attack_loudness
      @attack_duration = attack_duration
      super(offset)
    end
  end
  
  class Adjust < Instruction
    attr_reader :pitch
    def initialize offset, pitch
      @pitch = pitch
      super(offset)
    end
  end

  class Restart < Start; end
  
  class Release < Instruction
    attr_reader :release_duration
    def initialize offset, release_duration
      @release_duration = release_duration
      super(offset)
    end
  end

  class Stop < Instruction
    def initialize offset
      super(offset)
    end
  end
end

end
end