module Music
module Performance

NoteOnEvent = Struct.new(:notenum, :accented)
NoteOffEvent = Struct.new(:notenum)
VolumeExpressionEvent = Struct.new(:volume)

end
end