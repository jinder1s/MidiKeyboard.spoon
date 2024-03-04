#!/usr/bin/env python3

notes = ( "C", ( "C#", "Db" ), "D", ( "D#", "Eb" ), "E", "F", ( "F#", "Gb" ), "G", ( "G#", "Ab" ), "A",  ( "A#", "Bb" ), "B" )
scaleMapping = ( "I", "IIb", "II", "IIIb", "III", "IV", "Vb", "V", "VIb", "VI", "VIIb", "VII" )
majorScale = ( "I",  "II",  "III", "IV",  "V",  "VI",  "VII" )
minorScale = ("I", "II", "IIIb", "IV", "V", "VIb", "VIIb")


chromatic_movements = {"major":[4,3],
             "minor":[3,4],
             "diminished": [3,3],
             "sus2": [2,5],
             "sus4": [4,1],
             # "augmented": [4,4],
             # "major6": [4,5],
             # "minor6": [3,6],
             }

scale_movements = {
    "scale" : [2,2],
    "sus2" : [1,3],
    "sus4": [3,1],
    "6":[2,3],
}

def createTriadChord(note, movement, notes):
    note_index = None
    for i, pos_note in enumerate( notes ):
        if note == pos_note or ( (isinstance(pos_note, list) or isinstance(pos_note, list))  and note in pos_note):
            note_index = i
            break
    chord = {notes[note_index]}
    next_note_index = note_index
    for move in movement:
        next_note_index = next_note_index + move
        if next_note_index >= len(notes):
            next_note_index -= len(notes)
        next_note = notes[next_note_index]
        chord.add(next_note)

    return chord

if __name__ == '__main__':
    output = {}
    list_of_chords = []
    set_of_chords = set()
    chords2 = {}
    current_movements = chromatic_movements
    current_notes = scaleMapping
    chord_parent_notes = majorScale
    for movement in current_movements:
        output[movement]={}

        for note in chord_parent_notes:
            note = note if isinstance(note, str) else note[0]
            chord = createTriadChord(note, current_movements[movement], current_notes)
            output[movement][note] = chord
            list_of_chords.append(chord)
            set_of_chords.add(frozenset( chord ))
            if frozenset(chord) not in chords2:
                chords2[frozenset(chord)]=[]
            chords2[frozenset(chord)].append((note, movement ))


    print(f'l c:{len(list_of_chords)}, ls: {len(set_of_chords)} ')
    for chord, c_movments in chords2.items():
        if len(c_movments) > 1:
            print(f'conflict: {chord}: {c_movments}')
    scale_chords = [chord for chord in list_of_chords if len(chord) == len([note for note in chord if note in majorScale]) ]
    print(f'lsc: {len(scale_chords)}')

# if __name__ == '__main__':
#     print(createTriadChord("II", current_movements["major"], current_notes))
#     print(createTriadChord("IIb", current_movements["major"], current_notes))
