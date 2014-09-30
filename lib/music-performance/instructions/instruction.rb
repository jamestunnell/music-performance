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
    attr_reader :pitch, :attack_time, :attack_height, :sustain_height
    def initialize offset, pitch, attack_time, attack_height, sustain_height
      @pitch = pitch
      @attack_time = attack_time
      @attack_height = attack_height
      @sustain_height = sustain_height
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
    attr_reader :release_time
    def initialize offset, release_time
      @release_time = release_time
      super(offset)
    end
  end

  # Stores information needed to end a note.
  class Stop < Instruction
    def initialize offset
      super(offset)
    end
  end
end

end
end