;~ bezumie_same_init_cursor.au3
;~ makes sure the mouse cursor is positioned correctly
;~ http://bezumie.com/same/index.php

Local $orig = MouseGetPos()
;~ Move left until color 3178704 is found
While PixelGetColor($orig[0], $orig[1]) <> 3178704
	$orig[0] = $orig[0] - 1
WEnd
;~ Move down to the corner of the game field
While PixelGetColor($orig[0], $orig[1] + 1) == 3178704
	$orig[1] = $orig[1] + 1
WEnd
;~ Set cursor to the center of the most bottom left tile
MouseMove($orig[0] + 10, $orig[1] - 10, 0)