module Music
module Performance

class ScoreSequencer
  def initialize score
    start_nps = NoteTimeConverter.notes_per_second(score.start_tempo,
      score.start_meter.beat_duration)
    @start_usec_per_qnote = MidiUtil.usec_per_qnote(start_nps)
    @parts = ScoreCollator.new(score).collate_parts
  end

  def make_midi_seq
    seq = MIDI::Sequence.new()
    
    # first track for the sequence holds time sig and tempo events
    track0 = MIDI::Track.new(seq)
    seq.tracks << track0
    track0.events << MIDI::Tempo.new(@start_usec_per_qnote)
    track0.events << MIDI::MetaEvent.new(MIDI::META_SEQ_NAME, 'Sequence Name')
    
    channel = 0
    @parts.each do |part_name,part|
      pseq = PartSequencer.new(part)
      seq.tracks << pseq.make_midi_track(seq, part_name, channel, seq.ppqn)
      channel += 1
    end
    
    return seq
  end
end

end
end
