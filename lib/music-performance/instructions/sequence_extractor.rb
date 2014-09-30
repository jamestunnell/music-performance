module Music
  
module Transcription
  class Note
    def rest?
      @pitches.empty?
    end
  end
end

module Performance

class SequenceExtractor
  def extract_sequences part
    sequences = []
    
    offset = 0
    part.notes.each do |note|
      unless note.rest?
        seqs = note.pitches.map do |p|
          opn = OnePitchNote.new(note.duration, p, note.accent, note.links[p])
          InstructionSequence.new(offset, [opn])
        end
        sequences.concat seqs
      end
      offset += note.duration
    end
        
    return sequences
  end
end

end
end