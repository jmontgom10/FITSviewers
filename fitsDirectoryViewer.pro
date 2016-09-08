; This is a simple script file used to launch a small GUI for viewing all the
; FITS files (or a selected set of fits files) in a directory.
;

; Define a function to empty the keyboard buffer after each image display
pro empty_keyboard_buffer
  repeat begin
    ans = get_kbrd(0)
  endrep until ans eq ''
  return
end

FITSdirectory = DIALOG_PICKFILE(/READ, /DIRECTORY)
CD, FITSdirectory, CURRENT = oldDir
fileList = FILE_SEARCH('*.FITS', /FULLY_QUALIFY_PATH, COUNT = fileCount)
CD, oldDir

IF fileCount EQ 0 THEN BEGIN
  PRINT, 'No FITS files found. Try again...'
  RETALL
ENDIF

; Build a square window in which to display the image
WINDOW, 21, XS = 800, YS = 800

fileInd = 0
done    = 0
WHILE ~done DO BEGIN
  ; Ensure that fileInd is within a reasonable range
  IF fileInd LT 0 THEN fileInd = (fileCount - 1)
  IF fileInd GT (fileCount - 1) THEN fileInd = 0

  ; Select the image to display
  thisFile = fileList[fileInd]
  displayImg = READFITS(thisFile, /SILENT)

  ; Compute the image statistics
  SKY, displayImg, skyMode, skyNoise, /SILENT
  
  ; Display the image to the user (and some instructions)
  TVIM, displayImg, RANGE = skyMode + [-3,+10]*skyNoise, $
    TITLE = FILE_BASENAME(thisFile)
  XYOUTS, 0.5, 0.02, 'A - previous, S - next, Q - quit' , /NORMAL, ALIGNMENT = 0.5
  
  ; Clear out the keyboard buffer
  EMPTY_KEYBOARD_BUFFER

  ; Wait for the user to specify what to do next
  keyDone = 0
  WHILE ~keyDone DO BEGIN
    ; Retrieve the user keystroke
    char = STRUPCASE(GET_KBRD(1))
    
    ; Test if the keystroke is acceptable
    CASE char OF
      'A': BEGIN
        fileInd--
        keyDone = 1
      END
      'S': BEGIN
        fileInd++
        keyDone = 1
      END
      'Q': BEGIN
        WDELETE, 21
        PRINT, 'Done!'
        RETALL
      END
      ELSE: BEGIN
        PRINT, 'Keystroke not recognized... are you using Dvorak? ;-)'
      END
    ENDCASE
  ENDWHILE
ENDWHILE
END