module Music
module Performance

NoteOnEvent = Struct.new(:notenum, :accented)
NoteOffEvent = Struct.new(:notenum)

end
end