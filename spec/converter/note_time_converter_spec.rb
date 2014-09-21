require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NoteTimeConverter do
  describe '.notes_per_second' do
    it 'should multiply tempo and beat duration, then divide by 60' do
      nps = NoteTimeConverter.notes_per_second(120,"1/4".to_r)
      nps.should eq("1/2".to_r)
    end
  end

  describe '#notes_per_second_at' do
    it 'should invoke .notes_per_second using current tempo and beat duration values' do
      tc = ValueComputer.new(
        120, 1 => Change::Gradual.new(100,1), 2 => Change::Gradual.new(150,1))
      bdc = ValueComputer.new Rational(1,4)
      converter = NoteTimeConverter.new(tc,bdc,200)
      (0..2).step(0.2).each do |offset|
        tempo = tc.value_at(offset)
        beat_duration = bdc.value_at(offset)
        nps = NoteTimeConverter.notes_per_second(tempo,beat_duration)
        converter.notes_per_second_at(offset).should eq nps
      end
    end
  end
  
  describe "#time_elapsed" do
    context "constant tempo" do
      before :each do
        @tempo_computer = ValueComputer.new 120
        @beat_duration_computer = ValueComputer.new Rational(1,4)
        sample_rate = 48
        @converter = NoteTimeConverter.new(
          @tempo_computer, @beat_duration_computer, sample_rate)
      end
  
      it "should return a time of zero when note end is zero." do
        @converter.time_elapsed(0, 0).should eq(0)
      end
      
      it "should return a time of 1 second when note end is equal to the initial notes-per-second" do
        note_end = @converter.notes_per_second_at(0)
        @converter.time_elapsed(0, note_end).should eq(1)
      end
    end
    
    context "linear tempo-change" do
      before :each do
        @tempo_computer = ValueComputer.new(
          120, 1 => Change::Gradual.new(60, 1))
        @beat_duration_computer = ValueComputer.new(Rational(1,4))
        sample_rate = 200
        @converter = NoteTimeConverter.new(
          @tempo_computer, @beat_duration_computer, sample_rate)
      end
  
      it "should return a time of zero when note end is zero." do
        @converter.time_elapsed(0.0, 0.0).should eq(0.0)
      end
  
      it "should return a time of 3 sec during a 1-note long transition from 120bpm to 60bpm" do
        @converter.notes_per_second_at(1.0).should eq(0.5)
        @converter.notes_per_second_at(2.0).should eq(0.25)
  
        @converter.time_elapsed(1.0, 2.0).should be_within(0.05).of(2.77)
      end
  
    end
  end
  
  describe "#map_note_offsets_to_time_offsets" do
    context "constant tempo" do
      before :each do 
        @tempo_computer = ValueComputer.new 120
        @beat_duration_computer = ValueComputer.new Rational(1,4)
        sample_rate = 4800
        @converter = NoteTimeConverter.new(
          @tempo_computer, @beat_duration_computer, sample_rate)
      end
  
      it "should map offset 0.0 to time 0.0" do
        map = @converter.map_note_offsets_to_time_offsets [0.0]
        map[0.0].should eq(0.0)
      end

      it "should map offset 0.25 to time 0.5" do
        map = @converter.map_note_offsets_to_time_offsets [0.0, 0.25]
        map[0.25].should eq(0.5)
      end
      
      it "should map offset 1.0 to time 2.0" do
        map = @converter.map_note_offsets_to_time_offsets [0.0, 1.0]
        map[1.0].should eq(2.0)
      end
    end
  end
end
