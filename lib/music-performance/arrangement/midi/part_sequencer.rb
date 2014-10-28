module Music
module Performance

class PartSequencer
  def initialize part, cents_per_step = 10
    extractor = NoteSequenceExtractor.new(part.notes, cents_per_step)
    note_sequences = extractor.extract_sequences
    
    @note_events = {}
    note_sequences.each do |note_seq|
      pitches = note_seq.pitches.sort
      pitches.each_index do |i|
        offset, pitch = pitches[i]
        
        accented = false
        if note_seq.attacks.has_key?(offset)
          accented = note_seq.attacks[offset].accented?
        end
        
        note_num = MidiUtil.pitch_to_notenum(pitch)
        on_at = offset
        off_at = (i < (pitches.size - 1)) ? pitches[i+1][0] : note_seq.stop
        
        add_event(on_at, NoteOnEvent.new(note_num, accented))
        add_event(off_at, NoteOffEvent.new(note_num))
      end
    end
  end
  
  def make_midi_track midi_sequence, part_name, channel, ppqn
    track = begin_track(midi_sequence, part_name, channel)
    
    prev_offset = 0
    event_offsets = @note_events.keys.sort
    while event_offsets.any?
      next_offset = event_offsets.shift
      delta = MidiUtil.delta(next_offset - prev_offset, ppqn)
      @note_events[next_offset].each do |event|
        track.events << case event
        when NoteOnEvent
          MIDI::NoteOn.new(channel, event.notenum, 127, delta)
        when NoteOffEvent
          MIDI::NoteOff.new(channel, event.notenum, 127, delta)
        end
        delta = 0
      end
      prev_offset = next_offset
    end
  
    #dynamic_comp = ValueComputer.new(
    #  part.start_dynamic, part.dynamic_changes)
    
   return track
  end
  
  private
  
  def add_event offset, event
    if @note_events.has_key? offset
      @note_events[offset].push event
    else
      @note_events[offset] = [ event ]
    end
  end

  def begin_track midi_sequence, part_name, channel
    # Track to hold part notes
    track = MIDI::Track.new(midi_sequence)
    
    # Name the track and instrument
    track.name = part_name
    track.instrument = MIDI::GM_PATCH_NAMES[0]
    
    # Add a volume controller event (optional).
    track.events << MIDI::Controller.new(channel, MIDI::CC_VOLUME, 127)
    
    # Change to particular instrument sound
    track.events << MIDI::ProgramChange.new(channel, 1, 0)
    
    return track
  end
end

end
end