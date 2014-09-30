require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ScoreTimeConverter do
  before :all do
    @score = Score.new(
      Meter.new(4,"1/4".to_r),
      120,
      program: Program.new([(1.to_r)...(2.to_r)]),
      parts: {
        "abc" => Part.new(
          Dynamics::MF,
          notes: [
            Note.new(0.1,[C5]),
            Note.new(0.2,[D5]),
            Note.new(0.3,[C5]),
            Note.new(0.4,[D5]),
          ]
        )
      },
    )
    @converter = ScoreTimeConverter.new(@score,1000)
  end

  describe '#convert_parts' do
    before :all do
      @timeparts = @converter.convert_parts
    end
    
    it 'should return a hash of Part objects' do
      @timeparts.values.count {|v| !v.is_a?(Part)}.should eq 0
    end
    
    it "should produce notes with duration appropriate to the tempo" do
      part = @timeparts.values.first
      part.notes[0].duration.should be_within(0.01).of(0.2)
      part.notes[1].duration.should be_within(0.01).of(0.4)
      part.notes[2].duration.should be_within(0.01).of(0.6)
      part.notes[3].duration.should be_within(0.01).of(0.8)
    end
    
    it "should produce notes twice as long when tempo is half" do
      score = @score.clone
      score.parts.values.first.notes.concat [
        Note.new(0.2,[C5]), Note.new(0.4,[D5]), Note.new(0.3,[C5]), Note.new(0.1,[D5]) ]
      score.tempo_changes[1.to_r] = Change::Immediate.new(60)
      converter = ScoreTimeConverter.new(score,1000)
      timeparts = converter.convert_parts
      
      part = timeparts.values.first
      part.notes[0].duration.should be_within(0.01).of(0.2)
      part.notes[1].duration.should be_within(0.01).of(0.4)
      part.notes[2].duration.should be_within(0.01).of(0.6)
      part.notes[3].duration.should be_within(0.01).of(0.8)
      
      part.notes[4].duration.should be_within(0.01).of(0.8)
      part.notes[5].duration.should be_within(0.01).of(1.6)
      part.notes[6].duration.should be_within(0.01).of(1.2)
      part.notes[7].duration.should be_within(0.01).of(0.4)      
    end
  end

  describe '#convert_program' do
    before :all do
      @timeprogram = @converter.convert_program
    end
    
    it 'should convert note offsets to time offsets' do
      timeseg = @timeprogram.segments[0]
      timeseg.first.should be_within(0.01).of(2)
      timeseg.last.should be_within(0.01).of(4)
    end
  end
end
