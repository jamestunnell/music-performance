module Music
module Performance

class ScoreNotValidError < StandardError; end

# Combine multiple program segments to one, using tempo/note/dynamic
# replication and truncation where necessary.
class ScoreCollator
  def initialize score
    unless score.valid?
      raise ScoreNotValidError, "errors found in score: #{score.errors}"
    end
    @score = score
  end
  
  def collate_parts
    segments = @score.program.segments
    
    Hash[
      @score.parts.map do |name, part|
	new_dcs = collate_changes(part.start_dynamic,
	  part.dynamic_changes, segments)
	new_notes = collate_notes(part.notes, segments)
	new_part = Music::Transcription::Part.new(part.start_dynamic,
	  dynamic_changes: new_dcs, notes: new_notes)
	[ name, new_part ]
      end
    ]
  end
  
  def collate_tempo_changes
    collate_changes(@score.start_tempo,
      @score.tempo_changes, @score.program.segments)
  end
  
  def collate_meter_changes
    collate_changes(@score.start_meter,
      @score.meter_changes, @score.program.segments)
  end
  
  private
  
  def collate_changes start_value, changes, program_segments
    new_changes = {}
    comp = ValueComputer.new(start_value,changes)
    segment_start_offset = 0.to_r
    
    program_segments.each do |seg|
      included = changes.select {|offset,change| offset > seg.first && offset < seg.last }
      included.each do |offset, change|
	if(offset + change.duration) > seg.last
	  change.duration = seg.last - offset
	  change.value = comp.value_at seg.last
	end
      end
      
      # find & add segment start value first
      value = comp.value_at seg.first
      offset = segment_start_offset
      new_changes[offset] = Music::Transcription::Change::Immediate.new(value)
      
      # add changes to part, adjusting for segment start offset
      included.each do |offset2, change|
	offset3 = (offset2 - seg.first) + segment_start_offset
	new_changes[offset3] = change
      end
      
      segment_start_offset += (seg.last - seg.first)
    end
    
    return new_changes
  end
  
  def collate_notes notes, program_segments
    new_notes = []
    program_segments.each do |seg|
      cur_offset = 0
      cur_notes = []
      
      l = 0
      while cur_offset < seg.first && l < notes.size
        cur_offset += notes[l].duration
        l += 1
      end
      
      pre_remainder = cur_offset - seg.first
      if pre_remainder > 0
        cur_notes << Music::Transcription::Note.new(pre_remainder)
      end
      
      # found some notes to add...
      if l < notes.size
        r = l
        while cur_offset < seg.last && r < notes.size
          cur_offset += notes[r].duration
          r += 1
        end
        
        cur_notes += Marshal.load(Marshal.dump(notes[l...r]))
        overshoot = cur_offset - seg.last
        if overshoot > 0
          cur_notes[-1].duration -= overshoot
          cur_offset = seg.last
        end
        
        cur_notes[-1].links.clear
      end
      
      post_remainder = seg.last - cur_offset
      if post_remainder > 0
        cur_notes << Music::Transcription::Note.new(post_remainder)
      end
        
      new_notes.concat cur_notes
    end
    return new_notes
  end
end

end
end
