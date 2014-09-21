require 'set'

module Music
module Performance

# Utility class to convert a score from note-based to time-based offsets
class ScoreTimeConverter

  def initialize score, sample_rate
    tempo_computer = ValueComputer.new(
      score.start_tempo, score.tempo_changes)
    
    bdcs = Hash[ score.meter_changes.map do |offset,change|
      newchange = change.clone
      newchange.value = change.value.beat_duration
      [offset, newchange]
    end ]
    beat_duration_computer = ValueComputer.new(
      score.start_meter.beat_duration, bdcs)
    
    @note_time_converter = NoteTimeConverter.new(
      tempo_computer, beat_duration_computer, sample_rate)
    @score = score
  end
  
  # Convert note-based offsets & durations to time-based. This eliminates
  # the use of tempo and meter during performance, producing a TimeScore
  # object.
  def make_time_score
    note_time_map = make_note_time_map(gather_all_offsets)
    
    newparts = {}
    @score.parts.each do |name,part|
      offset = 0
      
      newnotes = part.notes.map do |note|
        starttime = note_time_map[offset]
        endtime = note_time_map[offset + note.duration]
        offset += note.duration
        newnote = note.clone
        newnote.duration = endtime - starttime
        
        newnote
      end
      
      new_dcs = Hash[
        part.dynamic_changes.map do |offset, change|
          timeoffset = note_time_map[offset]
          newchange = change.clone
          newchange.duration = note_time_map[offset + change.duration]
          
          [timeoffset,newchange]
        end
      ]
      
      newparts[name] = Music::Transcription::Part.new(
        part.start_dynamic,
        notes: newnotes,
        dynamic_changes: new_dcs
      )
    end
    
    newsegments = @score.program.segments.map do |segment|
      first = note_time_map[segment.first]
      last = note_time_map[segment.last]
      first...last
    end
    newprogram = Program.new(newsegments)
    
    TimeScore.new(newparts,newprogram)
  end
  
  private

  def gather_all_offsets
    note_offsets = Set.new [0]
    
    @score.parts.each do |name, part|
      offset = 0.to_r
      part.notes.each do |note|
        offset += note.duration
        note_offsets << offset
      end
      
      part.dynamic_changes.each do |change_offset, change|
        note_offsets << change_offset
        note_offsets << (change_offset + change.duration)
      end
    end
    
    @score.program.segments.each do |segment|
      note_offsets << segment.first
      note_offsets << segment.last
    end

    return note_offsets
  end
  
  def make_note_time_map note_offsets
    return @note_time_converter.map_note_offsets_to_time_offsets note_offsets
  end
end

end

module Transcription
  class Score
    def to_time_score sample_rate
      ScoreTimeConverter.new(self,sample_rate).make_time_score
    end
  end
end

end
