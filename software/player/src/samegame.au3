;~ samegame.au3
;~ This application either parses a samegame field ("parse") or
;~ converts a number sequence representing the solution for a samegame to mouse actions ("play").
;~ USAGE:
;~ samegame --config=<config> [--solution=<solution>]
;~   <config>      Path to the config file. E.g.:
;~                 .\path\to\config\my_samegame.cfg
;~   <solution>    Solution to the current game using the given <config>.
;~                 If <solution> is set, the given hits will be executed.
;~                 If not, the parsed game field will be written to SDTOUT.
;~ If a <solution> is given, the samegame will be played automatically ("play").
;~ Otherwise the samegame field will be converted to its string representation ("parse").
;~ e.g.:
;~ ./path/to/samegame.exe --config=./path/to/config/my_samegame.cfg
;~ ./path/to/samegame.exe --config=./path/to/config/my_samegame.cfg --solution=[22, 36, 2, 16, 13, 23, 2, 28, 7, 12, 10, 7, 6, 5, 2, 2, 2, 1]

#include <Process.au3>
#include <..\lib\samegame.au3>

;~ read configuration
Local $input = readConsole()
Local $config = readConfig($input[0])
Local $solution = readSolution($input[1])
Local $action
If $solution[1] == '' Then $action = 'parse'
If $solution[1] <> '' Then $action = 'play'
;~ [general]
Local $name = readAndCheck($config, 'general', 'name', False)
Local $resource = readAndCheck($config, 'general', 'resource', False)
Local $set_cursor = readAndCheck($config, 'general', 'set_cursor', False)
;~ [game settings]
Local $cols = readAndCheck($config, 'game settings', 'cols')
Local $rows = readAndCheck($config, 'game settings', 'rows')
Local $matrix[$cols][$rows]
Local $tile_width = readAndCheck($config, 'game settings', 'tile_width')
Local $tile_height = readAndCheck($config, 'game settings', 'tile_height')
Local $area = readAndCheck($config, 'game settings', 'area')
Local $clicks = readAndCheck($config, 'game settings', 'clicks')
Local $wait_after_click = readAndCheck($config, 'game settings', 'wait_after_click')
Local $wait_after_move = readAndCheck($config, 'game settings', 'wait_after_move')
;~ [color settings]
Local $color_tolerance = readAndCheck($config, 'color settings', 'color_tolerance')
Local $background_threshold = readAndCheck($config, 'color settings', 'background_threshold')
Local $background_compared = readAndCheck($config, 'color settings', 'background_compared')

;~ Execution
If FileExists($set_cursor) == 1 Then
  ;set initial mouse cursor position
  logger('Init     | mouse cursor position: ' & $set_cursor)
  _RunDOS($set_cursor)
EndIf
Local $orig = MouseGetPos() ;save initial mouse cursor position
;~ 	Move (slowly) back to the corner of the game field to make sure no tile group is hihglithed due to mouseover effects.
MouseMove($orig[0] - $tile_width, $orig[1] + $tile_height, 10)
Sleep($wait_after_move)
Local $colors = setColors($orig, $matrix, $tile_width, $tile_height, _
  $color_tolerance, $background_threshold, $background_compared) ;find and save all colors of the game field
If $action == 'play' Then
  logger('Play     | start, samegame (' & $name & ')...')
  MouseMove($orig[0], $orig[1], 0)
  playSolution($orig, $colors, $matrix, $tile_width, $tile_height, _
    $area, $solution, $clicks, $wait_after_click, $wait_after_move, _
    $color_tolerance, $background_threshold, $background_compared) ;execute the hits according to the given solution
  MouseMove($orig[0], $orig[1], 0)
  logger('Play     | done, samegame (' & $name & ')')
ElseIf $action == 'parse' Then
  logger('Parse    | start, samegame (' & $name & ')...')
  $matrix = parseScreenIntoMatrix($orig, $colors, $matrix, $tile_width, $tile_height, _
    $color_tolerance, $background_threshold, $background_compared) ;parse same game field
  MouseMove($orig[0], $orig[1], 0)
  ConsoleWrite(matrixToString($matrix) & @CRLF) ;print same game field to stdout
  logger('Parse    | result: ' & @CRLF & matrixToPrettyString($matrix) & @CRLF & matrixToString($matrix))
  logger('Parse    | done, samegame (' & $name & ')')
EndIf
