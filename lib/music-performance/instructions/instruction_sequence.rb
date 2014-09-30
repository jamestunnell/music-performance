module Music
module Performance

class InstructionSequence
  attr_reader :start, :stop
  
  def initialize offset, onepitch_notes
    first = onepitch_notes[0]
    @start = Instruction::Start.new(offset, first.pitch, 0, 0, 0)
    @middle = []
    onepitch_notes.each do |n|
      #m = []
      #@middle.concat(m)
      offset += n.duration
    end
    @stop = Instruction::Stop.new(offset)
  end
  
  def make_sequence_start onepitch_note, offset
    Instruction::Start.new(offset, onepitch_note.pitch, 0, 0, 0)
  end
  
  def make_sequence_middle onepitch_note, offset
    return 
  end
  
  def make_sequence_end onepitch_note, offset
  end
    
  def make_sequence onepitch_notes, offset
    sequence = [ make_sequence_start(onepitch_notes[0]) ]
    onepitch_notes.each do |n|
      sequence.concat(make_sequence_middle n)
      offset += n.duration
    end
    sequence.push(make_sequence_end(onepitch_notes[-1]))
    return sequence
  end
end

end
end