require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SequenceExtractor do
  describe '#extract_sequences' do
    context 'part with no notes' do
      it 'should return empty' do
        part = Part.new(Dynamics::MP, notes: [])
        seqs = SequenceExtractor.new.extract_sequences part
        seqs.should be_empty
      end
    end

    context 'part with only rest notes' do
      it 'should return empty' do
        part = Part.new(Dynamics::MP, notes: [ Note::Quarter.new, Note::Half.new ])
        seqs = SequenceExtractor.new.extract_sequences part
        seqs.should be_empty
      end
    end
    
    context 'part with only one note, single pitch' do
      before :all do
        @note = Note::Quarter.new([C5])
        part = Part.new(Dynamics::MP, notes: [ @note ])
        @seqs = SequenceExtractor.new.extract_sequences part
      end
      
      it 'should return array with one instr sequence' do
        @seqs.size.should eq 1
      end
      
      it 'should make start offset 0' do
        @seqs[0].start.offset.should eq 0
      end

      it 'should make stop offset the note duration' do
        @seqs[0].stop.offset.should eq @note.duration
      end
     
      #it 'should make a sequence matching output from SequenceMaker#make_sequences_from_note' do
      #  @seqs[0].should eq(@seq_maker.make_sequences_from_note(@note))
      #end
    end
    
    context 'part with only one note, multi pitch' do
      before :all do
        @note = Note::Quarter.new([C5,E5,G5])
        part = Part.new(Dynamics::MP, notes: [ @note ])
        @seqs = SequenceExtractor.new.extract_sequences part
      end
      
      it 'should return array with as many instr sequences as note pitches' do
        @seqs.size.should eq @note.pitches.size
      end
      
      it 'should make all start offsets 0' do
        @seqs.each {|s| s.start.offset.should eq 0 }
      end
      
      it 'should make all stop offsets the note duration' do
        @seqs.each {|s| s.stop.offset.should eq @note.duration }
      end
      
      #it 'should make multiple sequences matching output from SequenceMaker#make_sequences_from_note' do
      #  @seqs[0].should eq(@seq_maker.make_sequences_from_note(@note))
      #end
    end
  end
end
