(*
The MIT License (MIT)

Copyright (c) 2014 Robbert Brandsma

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*)

log "Started exporting photos"

set the destination to "/insert/your/absolute/photo/export/path/here/"

tell application "iPhoto"
	set theEvents to get every album
	repeat with aEvent in theEvents
		if (type of aEvent) is regular album then
			
			set shouldcopy to true
			if the name of aEvent is "Laatste import" then
				set shouldcopy to false
			end if
			
			set thepath to the name of aEvent
			# Repeat until the upper parent is found
			set thecurrentparent to the parent of aEvent
			
			try
				repeat while the type of thecurrentparent is folder album
					if the name of thecurrentparent is "Verzamelingen" then
						set shouldcopy to false
					end if
					
					set thisname to (get name of thecurrentparent)
					set thepath to thisname & "/" & thepath
					
					set thecurrentparent to the parent of thecurrentparent
				end repeat
			end try
			
			set thepath to destination & thepath & "/"
			
			# Create parent folder
			if shouldcopy then
				log "Copying to " & thepath
				
				do shell script "mkdir -p \"" & thepath & "\""
				
				set theImagePaths to image path of every photo of aEvent
				
				set totalphotos to count of theImagePaths
				set photoscopied to 0
				set lastreportpercentage to 0
				
				log (totalphotos as string) & " photos to be copied"
				
				repeat with theimagepath in theImagePaths
					do shell script "cp \"" & theimagepath & "\" \"" & thepath & "\""
					
					set photoscopied to photoscopied + 1
					set percentage to (photoscopied / totalphotos * 100) as integer
					if percentage is not lastreportpercentage then
						log (percentage as string) & "%"
						set lastreportpercentage to percentage
					end if
					
				end repeat
			else
				log "Not copying " & name of aEvent
			end if
		end if
	end repeat
end tell