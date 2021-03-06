require 'music-transcription'

require 'music-performance/version'

require 'music-performance/model/note_attacks'
require 'music-performance/model/note_sequence'

require 'music-performance/util/interpolation'
require 'music-performance/util/piecewise_function'
require 'music-performance/util/value_computer'
require 'music-performance/util/optimization'
require 'music-performance/util/note_linker'

require 'music-performance/conversion/note_time_converter'
require 'music-performance/conversion/score_time_converter'
require 'music-performance/conversion/score_collator'
require 'music-performance/conversion/glissando_converter'
require 'music-performance/conversion/portamento_converter'
require 'music-performance/conversion/note_sequence_extractor'

require 'midilib'
require 'music-performance/arrangement/midi/midi_util'
require 'music-performance/arrangement/midi/midi_events'
require 'music-performance/arrangement/midi/part_sequencer'
require 'music-performance/arrangement/midi/score_sequencer'