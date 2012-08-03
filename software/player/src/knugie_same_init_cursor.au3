;~ knugie_same_init_cursor.au3
;~ makes sure the mouse cursor is positioned correctly
;~ http://knugie.de/samegame/

Local $orig = MouseGetPos()
;~ Move left until white pixel is found
While PixelGetColor($orig[0], $orig[1]) <> 16777215
	$orig[0] = $orig[0] - 1
WEnd
;~ Move down to the corner of the game field
While PixelGetColor($orig[0] + 1, $orig[1]) <> 16777215
	$orig[1] = $orig[1] + 1
WEnd
;~ Set cursor to the center of the most bottom left tile
MouseMove($orig[0] + 15, $orig[1] - 15, 0)