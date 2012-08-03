;~ bricks_breaking_init_cursor.au3
;~ makes sure the mouse cursor is positioned correctly
;~ http://www.mindjolt.com/games/bricks-breaking

Local $orig = MouseGetPos()
;~ Move right until white pixel is found
While PixelGetColor($orig[0], $orig[1]) <> 16777215
	$orig[0] = $orig[0] + 1
WEnd
;~ Move up to the corner of the game field
While PixelGetColor($orig[0] - 1, $orig[1]) <> 16777215
	$orig[1] = $orig[1] - 1
WEnd
;~ Set cursor to the center of the most bottom left tile
MouseMove($orig[0] - 376, $orig[1] + 376, 0)
