require 'spec_helper'

describe ScoreCollator do
  describe '#collate_parts' do
    before :all do
      @part = Part.new(Dynamics::FF,
        notes: [ Note.quarter([C2]),
          Note.half([D2]),
          Note.half([E2])
      ])
    end
    
    context 'first note starts before the segment start' do
      context 'first note ends right at segment start' do
        it 'should not be included in the part' do
          score = Score.new(FOUR_FOUR, 120,
            parts: {1 => @part},
            program: Program.new(["1/4".to_r..."5/4".to_r]))
          collator = ScoreCollator.new(score)
          parts = collator.collate_parts
          notes = parts[1].notes
          notes.size.should eq(@part.notes.size - 1)
          notes[0].pitches[0].should eq D2
          notes[1].pitches[0].should eq E2
        end
      end
      
      context 'first note ends after segment start' do
        it 'should not be included in the part, and a rest is inserted' do
          score = Score.new(FOUR_FOUR, 120,
            parts: {1 => @part},
            program: Program.new(["1/8".to_r..."5/4".to_r]))
          collator = ScoreCollator.new(score)
          parts = collator.collate_parts
          notes = parts[1].notes
          notes.size.should eq(@part.notes.size)
          notes[0].pitches.should be_empty
          notes[0].duration.should eq "1/8".to_r
          notes[1].pitches[0].should eq D2
          notes[2].pitches[0].should eq E2
        end
      end
    end
    
    context 'first note starts at segment start' do
      context 'last note starts at program end' do
        it 'should not be included in the part' do
          score = Score.new(FOUR_FOUR, 120,
            parts: {1 => @part},
            program: Program.new([0.to_r..."3/4".to_r]))
          collator = ScoreCollator.new(score)
          parts = collator.collate_parts
          notes = parts[1].notes
          notes.size.should eq(@part.notes.size - 1)
        end
      end
      
      context 'last note start before program end, but lasts until after' do
        it 'should be included in the part, but truncated' do
          score = Score.new(FOUR_FOUR, 120,
            parts: {1 => @part},
            program: Program.new([0.to_r...1.to_r]))
          collator = ScoreCollator.new(score)
          parts = collator.collate_parts
          notes = parts[1].notes
          notes.size.should eq(@part.notes.size)
          notes[-1].duration.should eq("1/4".to_r)
        end
      end
      
      context 'last note ends before program segment end' do
        it 'should insert a rest between last note end and segment end' do
          score = Score.new(FOUR_FOUR, 120,
            parts: {1 => @part},
            program: Program.new([0.to_r..."6/4".to_r]))
          collator = ScoreCollator.new(score)
          parts = collator.collate_parts
          notes = parts[1].notes
          notes.size.should eq(@part.notes.size + 1)
          notes[-1].pitches.should be_empty
          notes[-1].duration.should eq("1/4".to_r)
        end
      end
    end
    
    it 'should preserve links' do
      notes = Parsing::notes("1Db4~Bb4")
      score = Score.new(
        FOUR_FOUR,120,
        parts: { "lead" => Part.new(Dynamics::MP, notes: notes) },
        program: Program.new([0..1,0..1]),
      )
      collator = ScoreCollator.new(score)
      parts = collator.collate_parts
      
      notes = parts["lead"].notes
      notes.size.should eq 2
      notes.each do |note|
        note.links.should have_key(Db4)
        note.links[Db4].should be_a Link::Glissando
      end
    end
  end
  
  describe '#collate_tempo_changes' do
    before :all do
      @change0 = Change::Immediate.new(120)
      @change1 = Change::Immediate.new(200)
      @change2 = Change::Gradual.new(100,1)
    end
    
    context 'tempo change at end of program segment' do
      it 'should not be included in the tempo changes' do
        score = Score.new(FOUR_FOUR, 120, tempo_changes: {
          1 => @change1, 2 => @change2 }, program: Program.new([0..2]))
        collator = ScoreCollator.new(score)
        tcs = collator.collate_tempo_changes
        tcs.size.should eq 2
        tcs[0.to_r].should eq @change0
        tcs[1.to_r].should eq @change1
      end
    end
    
    context 'tempo change starts before segment end, lasts until after' do
      it 'should be included in the tempo changes, but truncated' do
        score = Score.new(FOUR_FOUR, 120, tempo_changes: {
          1 => @change1, 2 => @change2 }, program: Program.new([0..2.5]))
        collator = ScoreCollator.new(score)
        tcs = collator.collate_tempo_changes
        tcs.size.should eq 3
        tcs[0.to_r].should eq @change0
        tcs[1.to_r].should eq @change1
        tcs[2.to_r].should eq @change2
        tcs[2.to_r].duration.should eq(0.5)
        tcs[2.to_r].value.should eq(150.0)
      end
    end
  end

  describe '#collate_meter_changes' do
    it 'should behave just as #collate_tempo_changes' do
      change0 = Change::Immediate.new(FOUR_FOUR)
      change1 = Change::Immediate.new(THREE_FOUR)
      change2 = Change::Immediate.new(SIX_EIGHT)
      score = Score.new(FOUR_FOUR, 120, meter_changes: {
        1 => change1, 2 => change2 }, program: Program.new([0...2]))
      collator = ScoreCollator.new(score)
      tcs = collator.collate_meter_changes
      tcs.size.should eq 2
      tcs[0.to_r].should eq change0
      tcs[1.to_r].should eq change1
    end
  end
end
