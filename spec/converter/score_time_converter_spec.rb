require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ScoreTimeConverter do
  describe '#make_time_score' do
    before :all do
      @score = Score.new(
        Meter.new(4,"1/4".to_r),
        120,
        program: Program.new([1.0...2.0]),
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
      converter = ScoreTimeConverter.new(@score,1000)
      @timescore = converter.make_time_score
    end
    
    it 'should return a TimeScore object' do
      @timescore.should be_a TimeScore
    end
    
    it "should produce notes with duration appropriate to the tempo" do
      part = @timescore.parts.values.first
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
      timescore = converter.make_time_score
      
      part = timescore.parts.values.first
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
end
