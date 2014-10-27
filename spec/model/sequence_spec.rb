require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sequence do
  describe '#initialize' do
    before :all do
    end
    
    it 'should assign given start, stop, pitches and attacks' do
      start, stop = 15, 22
      pitches = { 15 => F2, 16 => G2, 16.1 => Ab2, 21.99 => C2 }
      attacks = { 15 => ACCENTED, 17 => UNACCENTED, 18 => ACCENTED }
      seq = Sequence.new(start,stop,pitches,attacks)
      seq.start.should eq(start)
      seq.stop.should eq(stop)
      seq.pitches.should eq(pitches)
      seq.attacks.should eq(attacks)
    end
    
    it 'should raise ArgumentError if start offset >= stop offset' do
      expect do
        Sequence.new(20,19, { 20 => C4 }, { 20 => UNACCENTED })
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if no pitches are given' do
      expect do
        Sequence.new(20,21, {}, { 20 => UNACCENTED })
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if no attacks are given' do
      expect do
        Sequence.new(20,21, { 20 => C4 }, {})
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if no start pitch is given' do
      expect do
        Sequence.new(20,21, { 20.1 => C4 }, { 20 => UNACCENTED })
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if no start attack is given' do
      expect do
        Sequence.new(20,21, { 20 => C4 }, { 20.1 => UNACCENTED })
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if any pitch offset is not between start..stop' do
      expect do
        Sequence.new(20,21, { 20 => C4, 21.01 => D4 }, { 20 => UNACCENTED })
      end.to raise_error(ArgumentError)
      
      expect do
        Sequence.new(20,21, { 20 => C4, 19.99 => D4 }, { 20 => UNACCENTED })
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if any attack offset is not between start..stop' do
      expect do
        Sequence.new(20,21, { 20 => C4 }, { 20 => UNACCENTED, 21.01 => ACCENTED })
      end.to raise_error(ArgumentError)
      
      expect do
        Sequence.new(20,21, { 20 => C4 }, { 20 => UNACCENTED, 19.99 => ACCENTED })
      end.to raise_error(ArgumentError)
    end
  end
end
