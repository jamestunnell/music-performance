module Music
module Performance

class Sequence
  def self.adjust_duration duration, articulation
    x = duration
    y = Math.log2(x)

    case articulation
    when Music::Transcription::Articulations::TENUTO
      x
    when Music::Transcription::Articulations::PORTATO
      x / (1 + 2**(y-1))
    when Music::Transcription::Articulations::STACCATO
      x / (1 + 2**(y))
    when Music::Transcription::Articulations::STACCATISSIMO
      x / (1 + 2**(y+1))
    else
      x - (1/16.0)*(1/(1+2**(-y)))
    end
  end

  attr_reader :start, :stop, :pitches, :attacks
  def initialize offset, elements
    @pitches = {}
    @attacks = {}
    @start = offset

    last = elements.last
    skip_attack = false
    elements.each do |el|
      @pitches[offset] = el.pitch
      unless skip_attack
        @attacks[offset] = Attack.new(el.accented)
      end

      if el.slurred?
        skip_attack = true
      end

      unless el.equal?(last)
        offset += el.duration
      end
    end

    @stop = offset + Sequence.adjust_duration(last.duration, last.articulation)
  end

  def duration; @stop - @start; end
end

end
end
