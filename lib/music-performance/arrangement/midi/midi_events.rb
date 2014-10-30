module Music
module Performance

class MidiEvent
  def <=> other
    ORDERING[self] <=> ORDERING[other]
  end
  
  class NoteOn < MidiEvent
    attr_reader :notenum, :accented
    def initialize notenum, accented
      @notenum, @accented = notenum, accented
    end
  end
  
  class NoteOff < MidiEvent
    attr_reader :notenum
    def initialize notenum
      @notenum = notenum
    end
  end
  
  class Expression < MidiEvent
    attr_reader :volume
    def initialize volume
      @volume = volume
    end
  end
  
  ORDERING = {
    NoteOffEvent => 0, VolumeExpressionEvent => 1, NoteOnEvent => 2
  }
end

end
end