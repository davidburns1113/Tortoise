# IMPORTS
require 'sinatra' # Use sinatra framework down the line
require 'rspec/autorun'

# CLASSES
class Note
	# Object that defines a note and the alphabet of notes, and individual transpositions.
	
	def initialize(tone,octave) # Constructor Method
		@value=tone+octave.to_s # Variable that defines the note, stored as a string - eg 'A5'
		@alphabet=['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'] # Library for use in transposition.
	end
	
	def read # Useful function for test purposes and for reading off the value in other class methods - we do not alter the value in other classes.
		return @value
	end
	
	def increment # Transposes a note up one semitone.
		unless @alphabet.include?@value[0..-2] # Makes sure note is a valid note - eg 'J4' fails here.
			raise "Invalid value for note in melody: " +@value
		end
		if @value[-1].to_i>=8 # Ensures 'C8' is the highest possible note.
			raise "Transposed melody out of range."
		end
		if @value[-1].to_i<0 # Ensures notes of negative octave range do not appear.
			raise "Transposed melody out of range."
		end
		for i in 0..11 do # Range used instead of indexing through list for ease of replacement.
			if @value[0..-2]==@alphabet[i] # [0..-2] indexing cuts off the last letter of the string, in this case the number, to ensure an alphabet element remains.
				begin
					@value[0..-2]=@alphabet[i+1] # Increments note by 1 semitone
				rescue # If i was the last element, on 'B', the above will fail. This snippet ensures that it continues.
					@value[0..-2]='C' # The octave number always rises on C so no need to search the alphabet.
					@value[1]=(@value[1].to_i+1).to_s # Increment the octave number.
				end
				break
			end
		end
	end	
end	

class Sequence # Class that defines a whole melody.
	
	def initialize(seq) # Constructor
		@values = seq # Sequence is an array defined by a comma seperated string. The actual forming of the array is done in the active section.
	end
	
	def test # Another useful method for cross-class value examination and test purposes.
		return @values
	end
	
	def noteconvert # Converts each element of the array from a string into a note with a value defined by that string.
		for i in 0..(@values.length-1) do # Index over whole array
			a=Note.new(@values[i][0..-2],@values[i][-1]) # Negative indexing used to ensure correct treatment for both A form and A# form notes.
			@values[i]=a # Overwrite values with associated notes.
		end
	end
	
	def shift(var=1) # Tranposes the whole melody by a defined shift.
		self.noteconvert # First convert the melody into notes - this will fail if noteconvert is run separately, so be careful in test.
		for i in 1..var # Repeat process for each shift
			for i in @values do # Index over all notes
				i.increment # Increment all notes
			end
		end
		#puts @values.length-1 # Test
		for i in 0..(@values.length-1) do # Convert array elements back into strings for easy output reading.
			@values[i]=@values[i].read # Overwrite all notes with their value variables.
		end
	end
	
	def output # Obtain nicely formatted output
		out="" # Setup output
		for i in @values do # Index over values
			out=out+i+", " # Ensure output is a comma separated list.
		end
		out[0..-2] # Print on webpage.
	end
	
end

# TESTS
describe Sequence do # Setup rspec
	it "Transposes" do # Basic test for functionality
		melody=Sequence.new(['B4','B4','C5','D5','D5','C5','B4','A4']) # Define test case
		melody.shift(4) # Define test shift
		tst=melody.test # Execute
		expect(tst).to eq(['D#5','D#5','E5','F#5','F#5','E5','D#5','C#5']) # Expect result
	end
	it "Catches Non-Integer Shifts" do # Test to ensure errors are raised for invalid shifts
		melody=Sequence.new(['B4','B4','C5','D5','D5','C5','B4','A4']) # Define test case
		expect{melody.shift('hello')}.to raise_error # Execute with impossible shift, expect failure
	end
	it "Catches Invalid Notes" do # Test to ensure all notes are valid.
		melody=Sequence.new(['B4','K4','C5','D5','D5','C5','B4','A4']) # Define impossible test case - exception is not raised until execution.
		expect{melody.shift(4)}.to raise_error # Attempt to execute, expect failure.
	end
	it "Catches Invalid Ranges" do # Test to ensure the ranges are stuck to.
		melody=Sequence.new(['B4','B4','C5','D5','D5','C5','B4','A4']) # Define test case.
		expect{melody.shift(400)}.to raise_error # Execute with shift outside reasonable range, expect failure.
	end
end

# ACTIVE CODE
get '/' do # Setup
	if params["shift"].to_i==0 # Ensure that shift is positive integer
		raise "Invalid value for shift: "+params["shift"].to_s # Call exception otherwise
	end
	mel=Sequence.new(params["melody"].split(',')) # Split melody input into an array, define sequence from it.
	mel.shift(params["shift"].to_i) # Shift method using shift input, does conversion to note, transposition and recovery.
	mel.output # Prints output.
end