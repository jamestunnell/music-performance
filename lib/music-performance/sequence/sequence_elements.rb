module Music
module Performance

SlurredElement = Struct.new(:duration, :pitch, :accented) do
  def slurred?; true; end
  def articulation; Music::Transcription::Articulations::NORMAL; end
end

LegatoElement = Struct.new(:duration, :pitch, :accented) do
  def slurred?; false; end
  def articulation; Music::Transcription::Articulations::NORMAL; end
end

FinalElement = Struct.new(:duration, :pitch, :accented, :articulation) do
  def slurred?; false; end
end

end
end