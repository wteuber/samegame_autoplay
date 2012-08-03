;~ samegame.au3
#include-once
#include <Array.au3>

;~ usage()
;~  Writes inforamtion about the program's usage to STDERR
;~ @param: (none)
;~ @return: (nothing)
Func usage()
  $self = StringRegExp(@AutoItExe, '(?:(?:.*?)\\)*(.*?\.exe)\z', 1)
  $self = $self[0]
  ConsoleWriteError('This application either parses a samegame field ("parse") or' & @CRLF & _
    'converts a number sequence representing the solution for a samegame to mouse actions ("play").' & @CRLF & _
    'USAGE:' & @CRLF & _
    $self & ' --config=<config> [--solution=<solution>]' & @CRLF & _
    '  <config>      Path to the config file. E.g.:' & @CRLF & _
    '                .\path\to\config\my_samegame.cfg' & @CRLF & _
    '  <solution>    Solution to the current game using the given <config>.' & @CRLF & _
    '                If <solution> is set, the given hits will be executed.' & @CRLF & _
    '                If not, the parsed game field will be written to SDTOUT.' & @CRLF & _
    'If a <solution> is given, the samegame will be played automatically ("play").' & @CRLF & _
    'Otherwise the samegame field will be converted to its string representation ("parse").' & @CRLF & _
    'e.g.:' & @CRLF & _
    './path/to/samegame.exe --config=./path/to/config/my_samegame.cfg' & @CRLF & _
    './path/to/samegame.exe --config=./path/to/config/my_samegame.cfg --solution=[22, 36, 2, 16, 13, 23, 2, 28, 7, 12, 10, 7, 6, 5, 2, 2, 2, 1]' & @CRLF)
EndFunc   ;==>usage

;~ logger($log = '')
;~  Writes message to STDERR
;~  E.g.: 2011/11/11 10:09:08.777>>    play samegame (my_samegame)
;~ @param:
;~  - $log (optional)  -  Message string, default: ''
;~ @return: Number  -  The number of characters written
Func logger($log = '')
  Return ConsoleWriteError(@YEAR & '/' & @MON & '/' & @MDAY& ' ' & @HOUR & ':' & @MIN & ':' & @SEC & '.' & @MSEC & '>>    ' & $log & @CRLF)
EndFunc   ;==>logger


;~ readConsole($input = "")
;~  checks for program parameters (args)
;~  Possible inputs are (ordered by priority):
;~   - internal String ($input)
;~   - STDIN (echo --config=<config> [--solution=<solution>] | this.exe)
;~   - commmand line (this.exe --config=<config> [--solution=<solution>])
;~ @param:
;~  - $input (optional)  -  args as string, default: ""
;~ @return: Array ([$config, $solution])
;~  - $config    -  String containing path and name of the config file (required)
;~  - $solution  -  Array, sequence of numbers representing hit positions.
Func readConsole($input = "")
  Local $sorted_args[2]
  If $input == "" Then
    While True
      $input &= ConsoleRead()
      If @error Then ExitLoop
    WEnd
  EndIf
  $input = StringReplace($input, @CR, "")
  $input = StringReplace($input, @LF, "")
  If $input == '' Then $input = _ArrayToString($CmdLine, ' ',1, UBound($CmdLine)-1)
  Local $config = StringRegExp($input, '(?:--config=(.*?)(?:--solution=|\z))', 1)
  If UBound($config) >= 1 Then
    $sorted_args[0] = $config[0]
  Else
    usage()
    logger('Error: --config not found')
    Exit
  EndIf
  Local $solution = StringRegExp($input, '(?:--solution=(.*?)(?:--config=|\z))', 1)
  If UBound($solution) >= 1 Then
    $sorted_args[1] = $solution[0]
  EndIf

  Return $sorted_args

EndFunc   ;==>readConsole

;~ readConfig($config_path = "")
;~  parses the config file path from STDIN
;~  and normalizes input. Exits if config file does not exist
;~ @param:
;~ 	- $config_path (optional)  -  config file including its path
;~ @return: String
Func readConfig($config_path = "")
  $config_path = StringReplace($config_path, @CR, "")
  $config_path = StringReplace($config_path, @LF, "")

  If FileExists($config_path) <> 1 Then
    usage()
    logger("Error: Could not find config file:" & @CRLF & _
      $config_path & @CRLF & _
      "Please make sure the config file exists.")
    Exit 2
  EndIf

  Return $config_path

EndFunc   ;==>readConfig

;~ readSolution($solution_string = "")
;~  parses samegame solution strings from STDIN
;~  and returns an array containing normalizes data
;~  e.g. converts the input string "[1,2, 3,4\n]" into an array [1,2,3,4]
;~ @param:
;~ 	- $solution_string (optional)  -  if a solution string is given, readInput() reads this string,
;~ 	                                  if not, the string is read from stdin.
;~ @return: Array  -  internal representation of a solution
Func readSolution($solution = "")
  $solution = StringReplace($solution, " ", "")
  $solution = StringReplace($solution, "[", "")
  $solution = StringReplace($solution, "]", "")
  $solution = StringReplace($solution, @CR, "")
  $solution = StringReplace($solution, @LF, "")

  Return StringSplit($solution, ",")

EndFunc   ;==>readSolution

;~ checkAndRead($filename, $section, $var, $needed = True)
;~  loads a variable from the config file and returns its value
;~ @param:
;~ 	- $filename         -  file name of the config file
;~  - $section          -  name of the section in the config file
;~  - $var              -  name of the variable
;~  - $needed (optional)  -  states if the program should exit, default: True
;~ @return: [variable value]
Func readAndCheck($filename, $section, $var, $needed = True)
  Local $error = "ERROR:VarNotFound"
  Local $cfg = IniRead($filename, $section, $var, $error)
  If $cfg == $error Then
    If $needed Then
      usage()
	  logger("Error: Could not find [" & $section & "]." & $var)
      Exit
    Else
      logger("Warning: Could not find [" & $section & "]." & $var)
    EndIf
  Else

    Return $cfg

  EndIf
EndFunc   ;==>readAndCheck

;~ matrixToString($matrix)
;~  converts an Array (game field) into a string. This is for output purpose only.
;~  e.g.: matrixToString([[1,2,3],[2,2,2],[1,3,3]]) returns "[[1,2,3],[2,2,2],[1,3,3]]"
;~ @param:
;~  - $matrix  -  a 2-dimensional Array of any size
;~ @return: String
Func matrixToString($matrix)
  Local $col_count = UBound($matrix)
  Local $row_count = UBound($matrix, 2)
  Local $colStrings[$col_count]
  Local $col, $row
  Local $output = "[["

  For $col = 0 to ($col_count - 1) Step 1
    $colStrings[$col] = ""
    For $row = 0 to ($row_count - 1) Step 1
      $colStrings[$col] = $colStrings[$col] & $matrix[$col][$row]
      If $row < ($row_count - 1) Then $colStrings[$col] = $colStrings[$col] & ','
    Next   ;$row
    $output = $output & $colStrings[$col]
    If $col < ($col_count - 1) Then
      $output = $output & '],['
    Else
      $output = $output & ']]'
    EndIf
  Next   ;$col

  Return $output

EndFunc   ;==>matrixToString

;~ matrixToPrettyString($matrix)
;~  converts an Array (game field) into a string. This is for output purpose only.
;~  e.g.: matrixToString([[1,2,3],[2,2,2],[1,3,3]]) returns "
;~ 3 2 3 
;~ 2 2 3 
;~ 1 2 1"
;~ @param:
;~  - $matrix  -  a 2-dimensional Array of any size
;~ @return: String
Func matrixToPrettyString($matrix)
  Local $col_count = UBound($matrix)
  Local $row_count = UBound($matrix, 2)
  Local $rowStrings[$row_count]
  Local $col, $row
  Local $output = ""

  For $row = ($row_count - 1) to 0 Step -1
    $rowStrings[$row] = ""    
    For $col = 0 to ($col_count - 1) Step 1
      $output = $output & $matrix[$col][$row] & ' '
    Next   ;$col
    If $row <> 0 Then
      $output = $output & @CRLF
    EndIf
  Next   ;$row

  Return $output

EndFunc   ;==>matrixToPrettyString

;~ rgb($color)
;~  converts the decimal number representation of a color into its RGB representation.
;~  e.g.: rgb(22624) returns [0,88,96], i.e. R:0, G:88, B:96
;~ @param:
;~  - $color  -  the decimal number representation of a color,
;~               the value should be between 0 and 16777215
;~ @return: Array
Func rgb($color)
  Dim $rgb[3]
  $hex = Hex($color, 6)
  $rgb[0] = Dec(StringMid($hex, 1, 2))
  $rgb[1] = Dec(StringMid($hex, 3, 2))
  $rgb[2] = Dec(StringMid($hex, 5, 2))
  Return $rgb
EndFunc   ;==>rgb


;~ parseScreenIntoMatrix($orig, $colors, $matrix, $tile_width, $tile_height)
;~  parses samegame game field from the screen depending on current mouse position
;~  and returns an array containing game field information (including colors)
;~  each color is represented by a number vakue greater than 0
;~  "color 0" is an empty tile, therefor the background
;~  e.g.
;~  [[1,2,3,2,3,1,3,2,1,0,0,0,1,3,3],
;~   [2,1,1,1,1,1,2,2,3,0,0,0,1,2,2],
;~   [3,1,3,1,3,3,1,1,1,1,1,0,2,2,2],
;~   [2,1,2,3,1,3,1,3,1,1,2,0,3,2,3],
;~   [1,1,3,1,1,2,1,3,1,1,1,2,2,1,2],
;~   [2,1,3,2,1,1,1,2,2,2,1,3,3,2,1],
;~   [1,2,3,3,2,3,2,1,1,3,2,2,3,1,3],
;~   [2,1,2,1,2,2,1,1,1,2,2,3,3,1,2],
;~   [2,2,1,2,3,3,1,2,1,2,3,2,2,3,2],
;~   [2,3,3,3,2,2,3,3,3,2,2,2,1,1,3],
;~   [2,1,2,1,2,3,2,1,2,1,2,2,1,3,1]]
;~ @param:
;~  - $orig                  -  initial mouse cursor position
;~  - $colors                -  array of colors in the game
;~  - $matrix                -  same game field representation
;~  - $tile_width            -  width of a tile in pixels
;~  - $tile_height           -  height of a tile in pixels
;~  - $color_tolerance       -  colors are considered the same if their difference is less or equal to this
;~                              value in each RGB component
;~  - $background_threshold  -  every color with each RGB component is compared to this value
;~  - $background_compared   -  states if the background is darker or brighter than the tiles
;~ @return: Array
Func parseScreenIntoMatrix($orig, $colors, $matrix, $tile_width, $tile_height, $color_tolerance, $background_threshold, $background_compared = 'lt')
  Local $x_offset = $orig[0]
  Local $y_offset = $orig[1]
  Local $col_count = UBound($matrix)
  Local $row_count = UBound($matrix, 2)
  Local $col, $row, $pxl, $rgb1, $rgb2, $color

  For $col = 0 To ($col_count - 1)
    For $row = 0 To ($row_count - 1)
      $matrix[$col][$row] = 0
      $pxl = PixelGetColor(($x_offset + $col * $tile_width), ($y_offset - $row * $tile_height))
      $rgb1 = rgb($pxl)
      If ($background_compared == "gt" Or $background_compared == "bright" Or $background_compared == "brighter" Or $background_compared == "light" Or $background_compared == "lighter") Then
        $is_background = (($rgb1[0] >= $background_threshold) And ($rgb1[1] >= $background_threshold) And ($rgb1[2] >= $background_threshold))
      Else
        $is_background = (($rgb1[0] <= $background_threshold) And ($rgb1[1] <= $background_threshold) And ($rgb1[2] <= $background_threshold))
      EndIf
      If (Not $is_background) Then
        For $color = 1 To $colors[0]
          $rgb2 = rgb($colors[$color])
          If (Abs($rgb1[0] - $rgb2[0]) <= $color_tolerance) And _
            (Abs($rgb1[1] - $rgb2[1]) <= $color_tolerance) And _
            (Abs($rgb1[2] - $rgb2[2]) <= $color_tolerance) Then
              $matrix[$col][$row] = $color
            ExitLoop
          EndIf
        Next   ;$color
      EndIf
    Next   ;$row
  Next   ;$col

  Return $matrix

EndFunc   ;==>parseScreenIntoMatrix

;~ setColors($orig, $matrix, $tile_width, $tile_height)
;~  parses samegame game field colors from the screen depending on current mouse position
;~  and returns an array containing color information
;~  e.g. [3, 16119103, 4210932, 272767]
;~  whish means, there are 3 colors: 16119103, 4210932 and 272767
;~ @param:
;~  - $orig                  -  initial mouse cursor position
;~  - $matrix                -  same game field representation
;~  - $tile_width            -  width of a tile in pixels
;~  - $tile_height           -  height of a tile in pixels
;~  - $color_tolerance       -  colors are considered the same if their difference is less or equal to this
;~                              value in each RGB component
;~  - $background_threshold  -  every color with each RGB component is compared to this value
;~  - $background_compared   -  states if the background is darker or brighter than the tiles
;~ @return: Array
Func setColors($orig, $matrix, $tile_width, $tile_height, $color_tolerance, $background_threshold, $background_compared = 'lt')
  Local $x_offset = $orig[0]
  Local $y_offset = $orig[1]
  Local $col_count = UBound($matrix)
  Local $row_count = UBound($matrix, 2)
  Local $colors, $allColors[$col_count * $row_count]
  Local $col, $row, $color, $color1, $color2, $found, $rgb, $is_background

  For $col = 0 to ($col_count - 1)
    For $row = 0 to ($row_count - 1)
      $pxl = PixelGetColor(($x_offset + $col * $tile_width), ($y_offset - $row * $tile_height))
      $rgb = rgb($pxl)
      If ($background_compared == "gt" Or $background_compared == "bright" Or $background_compared == "brighter" Or $background_compared == "light" Or $background_compared == "lighter") Then
        $is_background = (($rgb[0] >= $background_threshold) And ($rgb[1] >= $background_threshold) And ($rgb[2] >= $background_threshold))
      Else
        $is_background = (($rgb[0] <= $background_threshold) And ($rgb[1] <= $background_threshold) And ($rgb[2] <= $background_threshold))
      EndIf
        ;~ logger('(' & $rgb[0] & ',' & $rgb[1] & ',' & $rgb[2] & '): ' & $is_background & @CRLF)
      If ($is_background) Then
        $allColors[$col * $row_count + $row] = 0
      Else
        $allColors[$col * $row_count + $row] = $pxl
      EndIf
    Next   ;$row
  Next   ;$col

  $allColors = _ArrayUnique($allColors)

  ;~ Remove background colors (items with value 0)
  $found = 0
  For $color = 1 To $allColors[0]
    If ($allColors[$color - $found] == 0) Then
      _ArrayDelete($allColors, ($color - $found))
      $found = $found + 1
    EndIf
  Next   ;$color
  $allColors[0] = $allColors[0] - $found

  ;~ Combine similar colors to a single color
  For $color1 = 1 To $allColors[0]
    For $color2 = 1 To $allColors[0]
      $rgb1 = rgb($allColors[$color1])
      $rgb2 = rgb($allColors[$color2])
      If (Abs($rgb1[0] - $rgb2[0]) <= $color_tolerance) And _
          (Abs($rgb1[1] - $rgb2[1]) <= $color_tolerance) And _
          (Abs($rgb1[2] - $rgb2[2]) <= $color_tolerance) Then
        $color_res = Int(Round((($allColors[$color1] + $allColors[$color2]) / 2), 0))
        $allColors[$color1] = $color_res
        $allColors[$color2] = $color_res
      EndIf
    Next   ;$color2
  Next   ;$color1

  ;~ Remove length entry from array
  _ArrayDelete($allColors, 0)
  ;~ Remove duplicate entries and set length entry ([0]) again
  $colors = _ArrayUnique($allColors)

  Return $colors

EndFunc   ;==>setColors

;~ isHittable($area, $matrix, $col, $row, $col_count, $row_count, $reset = False)
;~  is a wrapper function for isHittable2() and isHittableGeneral().
;~ @param:
;~  - $area              -  number of least connected tiles to be "hittable"
;~  - $matrix            -  same game field representation
;~  - $col               -  the column of the position to be checked
;~  - $row               -  the row of the position to be checked
;~  - $col_count         -  number of columns in the same game field
;~  - $row_count         -  number of rows in the same game field
;~  - $reset (optional)  -  flag if the counter of connected tiles should be reset, default: False
;~ @return: Boolean
Func isHittable($area, $matrix, $col, $row, $col_count, $row_count, $reset = False)
  If ($area == 2) Then
    Return isHittable2($matrix, $col, $row, $col_count, $row_count)
  EndIf
  If ($area > 2) Then
    Global $hit_checked[$col_count][$row_count] ;represents the current state of the hit analysis
    Global $hittable = 0
    Return isHittableGeneral($matrix, $col, $row, $col_count, $row_count, $reset)
  EndIf
EndFunc   ;==>isHittable

;~ isHittable2($matrix, $col, $row, $col_count, $row_count)
;~  checks if a certain tile (position) of the given game field is hittable
;~  A tile is hittable, if one of its 4 neighbours has the same color.
;~  e.g. isHittable2([[1,0,0],[1,2,3],[1,2,1]], 1, 1) returns True
;~  and  isHittable2([[1,0,0],[1,2,3],[1,2,1]], 1, 2) returns False
;~ @param:
;~  - $matrix            -  same game field representation
;~  - $col               -  the column of the position to be checked
;~  - $row               -  the row of the position to be checked
;~  - $col_count         -  number of columns in the same game field
;~  - $row_count         -  number of rows in the same game field
;~ @return: Boolean
Func isHittable2($matrix, $col, $row, $col_count, $row_count)
  Local $check = $matrix[$col][$row]
  Local $check_east, $check_west, $check_south, $check_north

  If $check <= 0 Then Return False
  If (($col + 1) < $col_count) Then $check_east = $matrix[$col + 1][$row]
  If ($check == $check_east) Then Return True
  If (($col - 1) >= 0) Then $check_west = $matrix[$col - 1][$row]
  If ($check == $check_west) Then Return True
  If (($row + 1) < $row_count) Then $check_south = $matrix[$col][$row + 1]
  If ($check == $check_south) Then Return True
  If (($row - 1) >= 0) Then $check_north = $matrix[$col][$row - 1]
  If ($check == $check_north) Then Return True

  Return False

EndFunc   ;==>isHittable2

;~ isHittableGeneral($matrix, $col, $row, $col_count, $row_count, $reset = False)
;~   checks if a certain tile (position) of the given game field is hittable
;~   A tile is hittable, if one of its 4 neighbours has the same color.
;~   e.g. isHittable2([[1,0,0],[1,2,3],[1,2,1]], 1, 1) returns False
;~   and  isHittable2([[1,0,0],[1,2,3],[1,2,1]], 1, 0) returns True
;~ @param:
;~  - $matrix            -  same game field representation
;~  - $col               -  the column of the position to be checked
;~  - $row               -  the row of the position to be checked
;~  - $col_count         -  number of columns in the same game field
;~  - $row_count         -  number of rows in the same game field
;~  - $reset (optional)  -  flag if the counter of connected tiles should be reset, default: False
;~ @return: Boolean
Func isHittableGeneral($matrix, $col, $row, $col_count, $row_count, $reset = False)
  Local $check_east, $check_west, $check_south, $check_north
  Dim $hit_checked
  If ($matrix[$col][$row] <= 0) Then Return False
  If ($reset) Then
    Local $hit_col, $hit_row
    $hittable = 0
    $check_east = False
    $check_south = False
    $check_west = False
    $check_north = False
    For $hit_col = 0 to ($col_count - 1) Step 1
      For $hit_row = 0 to ($row_count - 1) Step 1
        $hit_checked[$hit_col][$hit_row] = False
      Next   ;$hit_row
    Next   ;$hit_col
  EndIf
  $hit_checked[$col][$row] = 1
  $hittable = $hittable + 1
  If ($hittable >= 3) Then Return True
  If (($col + 1) < $col_count) And ($hit_checked[$col + 1][$row] == False) And ($matrix[$col][$row] == $matrix[$col + 1][$row]) Then $check_east = isHittableGeneral($matrix, $col + 1, $row, $col_count, $row_count)
  If ($check_east) Then Return True
  If (($col - 1) >= 0) And ($hit_checked[$col - 1][$row] == False) And ($matrix[$col][$row] == $matrix[$col - 1][$row]) Then $check_south = isHittableGeneral($matrix, $col - 1, $row, $col_count, $row_count)
  If ($check_south) Then Return True
  If (($row + 1) < $row_count) And ($hit_checked[$col][$row + 1] == False) And ($matrix[$col][$row] == $matrix[$col][$row + 1]) Then $check_west = isHittableGeneral($matrix, $col, $row + 1, $col_count, $row_count)
  If ($check_west) Then Return True
  If (($row - 1) >= 0) And ($hit_checked[$col][$row - 1] == False) And ($matrix[$col][$row] == $matrix[$col][$row - 1]) Then $check_north = isHittableGeneral($matrix, $col, $row - 1, $col_count, $row_count)
  If ($check_north) Then Return True

  Return False

EndFunc   ;==>isHittableGeneral

;~ markForOneHit($matrix, $col_count, $row_count, $col, $row, $idx)
;~  is used to count all hittable areas in the given game field and
;~  to keep track of the processed tiles.
;~  markForOneHit() uses the global variable $checked
;~ @param:
;~  - $matrix     -  same game field representation
;~  - $col        -  the column of the position to be marked
;~  - $row        -  the row of the position to be marked
;~  - $col_count  -  number of columns in the same game field
;~  - $row_count  -  number of rows in the same game field
;~  - $idx        -  index of the hit
;~ @return: (nothing)
Func markForOneHit($matrix, $col, $row, $col_count, $row_count, $idx)
  Dim $checked
  $checked[$col][$row] = $idx
  If (($col + 1) < $col_count) And ($checked[$col + 1][$row] == False) And ($matrix[$col][$row] == $matrix[$col + 1][$row]) Then markForOneHit($matrix, $col + 1, $row, $col_count, $row_count, $idx)
  If (($col - 1) >= 0) And ($checked[$col - 1][$row] == False) And ($matrix[$col][$row] == $matrix[$col - 1][$row]) Then markForOneHit($matrix, $col - 1, $row, $col_count, $row_count, $idx)
  If (($row + 1) < $row_count) And ($checked[$col][$row + 1] == False) And ($matrix[$col][$row] == $matrix[$col][$row + 1]) Then markForOneHit($matrix, $col, $row + 1, $col_count, $row_count, $idx)
  If (($row - 1) >= 0) And ($checked[$col][$row - 1] == False) And ($matrix[$col][$row] == $matrix[$col][$row - 1]) Then markForOneHit($matrix, $col, $row - 1, $col_count, $row_count, $idx)

  Return

EndFunc   ;==>markForOneHit

;~ Func playSolution($orig, $colors, $matrix, $tile_width, $tile_height, $area, $solution, $clicks, $wait_after_click, $wait_after_move, $color_tolerance, $background_threshold, $background_compared)
;~  executes the given solution on the same game field
;~ @param:
;~  - $orig                  -  initial mouse cursor position
;~  - $colors                -  array of colors in the game
;~  - $matrix                -  same game field representation
;~  - $tile_width            -  width of a tile in pixels
;~  - $tile_height           -  height of a tile in pixels
;~  - $area                  -  number of least connected tiles to be "hittable"
;~  - $solution              -  sequence of numbers representing hit positions (Array)
;~  - $clicks                -  number of clicks needed to clear a group of tiles.
;~  - $wait_after_click      -  number of milliseconds the program should wait after an area has been removed
;~  - $wait_after_move       -  number of milliseconds the program should wait after the mouse curser has moved away from the game field
;~  - $color_tolerance       -  colors are considered the same if their difference is less or equal to this
;~                              value in each RGB component
;~  - $background_threshold  -  every color with each RGB component is compared to this value
;~  - $background_compared   -  states if the background is darker or brighter than the tiles
;~ @return: (nothing)
Func playSolution($orig, $colors, $matrix, $tile_width, $tile_height, $area, $solution, $clicks, $wait_after_click, $wait_after_move, $color_tolerance, $background_threshold, $background_compared)
  Local $idx, $solve_hit, $hit_idx, $col, $row
  Local $col_count = UBound($matrix)
  Local $row_count = UBound($matrix, 2)
  Global $checked[$col_count][$row_count] ;represents the current state of the field analysis

  For $idx = 1 To $solution[0] Step 1
    $solve_hit = $solution[$idx]
    $hit_idx = 0
    For $col = 0 To ($col_count - 1) Step 1
      For $row = 0 To ($row_count - 1) Step 1
        $checked[$col][$row] = False
      Next   ;$row
    Next   ;$col

    ;~ set $matrix according to screen
    $matrix = parseScreenIntoMatrix($orig, $colors, $matrix, $tile_width, $tile_height, $color_tolerance, $background_threshold, $background_compared)
    For $col = 0 To ($col_count - 1) Step 1
      For $row = 0 To ($row_count - 1) Step 1
        If ($checked[$col][$row] == False) And isHittable($area, $matrix, $col, $row, $col_count, $row_count, True) Then
          $hit_idx = $hit_idx + 1
          If $solve_hit == $hit_idx Then
            MouseClick("primary", ($orig[0] + $col * $tile_width), ($orig[1] - $row * $tile_height), $clicks)
            Sleep($wait_after_click)
            ;~ Move mouse out of game field to prevent mouse over effects causing parsing errors.
            If ($wait_after_move <> 0) Then
              MouseMove(($orig[0] - $tile_width), ($orig[1] + $tile_height), 10)
              Sleep($wait_after_move)
            EndIf
          Else
            markForOneHit($matrix, $col, $row, $col_count, $row_count, $hit_idx)
          EndIf
        EndIf
      Next   ;$row
    Next   ;$col
  Next   ;$idx
EndFunc   ;==>playSolution