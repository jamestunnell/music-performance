require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SequenceExtractor do
  describe '#initialize' do
    it 'should clone original notes' do
      notes = [ Note.quarter([C2]), Note.half, Note.half ]
      extr = SequenceExtractor.new(notes)
      extr.notes[0].should eq(notes[0])
      notes[0].transpose!(1)
      extr.notes[0].should_not eq(notes[0])
    end
  
    it 'should maintain the same number of notes' do
      extr = SequenceExtractor.new(
        [ Note.quarter, Note.half, Note.half ])
      extr.notes.size.should eq 3
    end
    
    it 'should remove any bad ties (tying pitch does not exist in next note' do
      extr = SequenceExtractor.new(
        [ Note.quarter([C4,E4], links: {C4 => Link::Tie.new}),
          Note.quarter([E4]) ]
      )
      extr.notes[0].links.should_not have_key(C4)
    end
    
    it 'should replace any good ties with slurs' do
      extr = SequenceExtractor.new(
        [ Note.quarter([C4,E4], links: {C4 => Link::Tie.new, E4 => Link::Tie.new}),
          Note.quarter([C4,E4]) ]
      )
      extr.notes[0].links[C4].should be_a Link::Slur
      extr.notes[0].links[E4].should be_a Link::Slur
    end
    
    it 'should remove dead slur/legato (where target pitch is non-existent)' do
      extr = SequenceExtractor.new(
        [ Note.quarter([C4,E4], links: { C4 => Link::Slur.new(D4), E4 => Link::Legato.new(F4) }),
          Note.quarter([C4]) ]
      )
      extr.notes[0].links.should be_empty
    end
    
    it 'should remove any link where the source pitch is missing' do
      extr = SequenceExtractor.new(
        [ Note.quarter([C4,D4,E4,F4,G4], links: {
            Bb4 => Link::Tie.new, Db4 => Link::Slur.new(C4),
            Eb4 => Link::Legato.new(D4), Gb4 => Link::Glissando.new(E4),
            Ab5 => Link::Portamento.new(F4)
          }),
          Note.quarter([C4,D4,E4,F4,G4])
      ])
      extr.notes[0].links.should be_empty
    end
    
    it 'should not remove portamento and glissando with non-existent target pitches' do
      extr = SequenceExtractor.new(
        [ Note.quarter([C4,D4]),
          Note.quarter([C4,D4,E4,F4,G4], links: {
            C4 => Link::Tie.new, D4 => Link::Slur.new(Eb4),
            E4 => Link::Legato.new(Gb4), F4 => Link::Glissando.new(A5),
            G4 => Link::Portamento.new(Bb5)}) ]
      )
      extr.notes[-1].links.size.should eq 2
      extr.notes[-1].links.should have_key(F4)
      extr.notes[-1].links.should have_key(G4)
    end
  end
  
  describe '#extract_sequences' do
    context 'empty note array' do
      it 'should return empty' do
        seqs = SequenceExtractor.new([]).extract_sequences
        seqs.should be_empty
      end
    end
  
    context 'array of only rest notes' do
      it 'should return empty' do
        notes = [ Note::quarter, Note::quarter ]
        seqs = SequenceExtractor.new(notes).extract_sequences
        seqs.should be_empty
      end
    end
    
    context 'array with only one note, single pitch' do
      before :all do
        @note = Note::quarter([C5])
        @seqs = SequenceExtractor.new([@note]).extract_sequences
      end
      
      it 'should return array with one sequence' do
        @seqs.size.should eq 1
      end
      
      it 'should start offset 0' do
        @seqs[0].start.should eq 0
      end
      
      it 'should stop offset <= note duration' do
        @seqs[0].stop.should be <= @note.duration
      end
    end
    
    context 'array with two slurred notes, single pitch' do
      before :all do
        @notes = [ Note.quarter([C5], articulation: SLUR), Note.quarter([D5]) ]
        @seqs = SequenceExtractor.new(@notes).extract_sequences
      end
      
      it 'should return array with one sequence' do
        @seqs.size.should eq 1
      end
      
      it 'should start offset 0' do
        @seqs[0].start.should eq 0
      end
      
      it 'should stop offset <= combined duration of the two notes' do
        @seqs[0].stop.should be <= (@notes[0].duration + @notes[1].duration)
      end      
    end
    
    # TODO: more tests!
  end
end
