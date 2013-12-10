
on buildTitle(originalText)
	set normalizedText to my replace(originalText, ":", "-")
	set finalTitle to my firstChars(normalizedText, 100)
	return finalTitle
end buildTitle

on replace(originalText, fromText, toText)
	set AppleScript's text item delimiters to the fromText
	set the item_list to every text item of originalText
	set AppleScript's text item delimiters to the toText
	set originalText to the item_list as string
	set AppleScript's text item delimiters to ""
	return originalText
end replace

on firstChars(originalText, maxChars)
	if length of originalText is less than maxChars then
		return originalText
	else
		set limitedText to text 1 thru maxChars of originalText
		return limitedText
	end if
end firstChars

on writeToFile(filename, filecontents)
	set the output to open for access file filename with write permission
	set eof of the output to 0
	write filecontents to the output starting at eof
	close access the output
end writeToFile

display dialog "Welcome to the Apple Notes exporter for Fetchnotes. Your notes will open and you will be asked to select a destination for the export file. Once this is complete, please upload the file at http://apple.fetchnotes.com. Please press \"OK\" to export your notes now." cancel button "Cancel" default button "OK"

tell application "Notes"
	activate
	set exportFolder to choose folder
	log exportFolder
	set counter to 0
	set totalText to "["
	log (count of notes)
	repeat with each in every note
		set noteBody to body of each
		set noteBody to my replace(noteBody, "Õ", "'")
		set noteBody to my replace(noteBody, "Ó", "\"")
		set noteBody to my replace(noteBody, "\\", "\\\\")
		set noteBody to my replace(noteBody, "\"", "\\\"")
		set noteBody to my replace(noteBody, "
", "\\n")
		set noteBody to my replace(noteBody, "	", " ")
		set noteTime to creation date of each
		set noteTimeString to weekday of noteTime & ", " & month of noteTime & " " & day of noteTime & ", " & year of noteTime & " " & time string of noteTime
		set noteTime to (do shell script "date -j -f \"%A, %B %d, %Y %T\" \"" & noteTimeString & "\" +\"%s\"")
		if counter < (count of notes) and counter ­ 0 then
			set totalText to (totalText as text) & ","
		end if
		set totalText to (((totalText as text) & "{\"text\":\"" & noteBody as text) & "\", \"time\":\"" & noteTime as text) & "\"}"
		
		set counter to counter + 1
	end repeat
	
	set totalText to (totalText as text) & "]"
	set filename to ((exportFolder as string) & "mynotes" & ".json")
	my writeToFile(filename, totalText as text)
	display dialog "Your notes have been exported. Please upload the \"mynotes.json\" file to http://apple.fetchnotes.com/"
	do shell script "open " & quoted form of POSIX path of exportFolder
	
end tell
