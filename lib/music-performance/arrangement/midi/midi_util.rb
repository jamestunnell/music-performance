module Music
module Performance

class MidiUtil
  QUARTER = Rational(1,4)    
  def self.delta duration, ppqn
    pulses = (duration / QUARTER) * ppqn
    return pulses.round
  end
  
  def self.usec_per_qnote notes_per_sec
    spn = 1.0 / notes_per_sec
    spqn = spn / 4.0
    return (spqn * 1_000_000).to_i
  end
  
  p0 = Music::Transcription::Pitch.new(octave:-1,semitone:0)
  MIDI_NOTENUMS = Hash[
    (0..127).map do |note_num|
      [ p0.transpose(note_num), note_num ]
    end
  ]
  
  def self.pitch_to_notenum pitch
    MIDI_NOTENUMS[pitch.round]
  end
  
  def self.dynamic_to_volume dynamic
    (dynamic * 127).round
  end
end

end
end