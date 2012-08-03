// Original:  Jason Fondren (usher@betterbox.net)
// Modified:  Wolfgang Teuber


//	Preload and identify all of the images.
//	Default config for the script only uses
//	three different colored balls.
//	0=blank  1=red  2=yellow  3=blue

off0 = new Image();
off0.src = "black.gif";
off1 = new Image();
off1.src = "1off.gif";
off2 = new Image();
off2.src = "2off.gif";
off3 = new Image();
off3.src = "3off.gif";
on0 = new Image();
on0.src = "black.gif";
on1 = new Image();
on1.src = "1on.gif";
on2 = new Image();
on2.src = "2on.gif";
on3 = new Image();
on3.src = "3on.gif";

//	Declare the total score and the winner variable.
//
total = 0;
winner = 0;

//	Bottom row array, used by the
//	findAdjacent2() function.

bottom = new Array();
n = 0;
for (i = 0; i < 15; i++) {
  bottom[i] = n;
  n += 10;
}

//	Top row array, used by the
//	findAdjacent2() function.

head = new Array();
n = 9;
for (i = 0; i < 15; i++) {
  head[i] = n;
  n += 10;
}

//	Main array, randomly seeds all
//	coordinates with a number
//	from 1-3.

main = new Array();
for (i = 0; i < 150; i++) {
  main[i] = random();
}

//	The random number function. Change the
//	ballCount variable to add more colors
//	(which would make the game harder).
//	If you do this you must preload more images.

function random() {
  ballCount = 3;
  randomNum = Math.floor((Math.random() * ballCount));
  randomNum++;
  return randomNum;
}

//	Uses findAdjacent() to find connected balls
//	of the same color. Called on mouseover, changes
//	the ball image to alert user of how many
//	balls will be removed.

function onBall(numba) {
  if (main[numba] != 0) {
    crayon = main[numba];
    findAdjacent(numba);
    if (adj.length > 1) {
      for (n = 0; n < adj.length; n++) {
        document["img" + adj[n]].src = eval("on" + crayon + ".src");
        document.scores.click.value = (adj.length-2)*(adj.length-2);
      }
    }
  }
}

//	Uses findAdjacent() to find connected balls
//	of the same color. Turns off the alternate
//	balls on mouseout.

function offBall(numba) {
  if (main[numba] != 0) {
    crayon = main[numba];
    findAdjacent(numba);
    if (adj.length > 1) {
      for (n = 0; n < adj.length; n++) {
        document["img" + adj[n]].src = eval("off" + crayon + ".src");
        document.scores.click.value = 0;
      }
    }
  }
}

//	Uses findAdjacent() to find connected balls
//	of the same color. Removes selected balls by
//	changing the value to 0, cleans up columns
//	using slideBalls(), updates the game board
//	with startUp(), adjusts the score, and checks
//	to see if the game board is cleared with
//	checkwinner() or if all the removable pieces
//	are taken with checkLoser().

function clickBall(numba) {
  if (main[numba] != 0) {
    findAdjacent(numba);
    if (adj.length > 1) {
      for (n=0; n<adj.length; n++) {
        main[adj[n]] = 0;
      }
      slideBalls();
      startUp();
      total = (adj.length - 2) * (adj.length - 2) + total;
      document.scores.show.value = total;
      document.scores.click.value = 0;
      winTotal = total + 1000;
      if (checkWinner()) {
        //Allows you to write high scores to a file.
        //document.location = ("score.cgi?s=s&shots=" + winTotal)
        //winner = 1;
        document.scores.round.value = parseInt(document.scores.round.value) + 1;
        seed(false);
      }
      q = 0;
      checkLoser();
      if (q == 60 && winner == 0) {
        alert("Game Over!\n You scored "+document.scores.show.value+" points.");
      }
    }
  }
}

//	Rolls through the remaining balls
//	and checks to see if any more can
//	be removed with smallAdjacent().
//	If you set this function to check
//	much higher than main[60] Netscape
//	will give you a "too much recursion"
//	error, so there is a small chance that
//	this function will think the game is
//	over before it really is.

function checkLoser() {
  if (q == 60) {
    return true
  }
  if (main[q] != 0) {
    if (smallAdjacent(q)) {
      return false;
    }
  }
  q++;
  checkLoser();
}

//	Checks to see if the game was won.
//	Simply checks main[0], and if it
//	equals 0 returns true

function checkWinner() {
  if (main[0] == 0) {
    return true;
  }
}

//	A smaller faster version of
//	findAdjacent2(). Runs through
//	the balls until it finds the first
//	set of adjacent balls. Used by
//	checkLoser() to determine if the
//	game is over.

function smallAdjacent(numba) {
  isBottom = 0;
  isHead = 0;
  for (n = 0; n < 20; n++) {
    if (numba == head[n]) {
      isHead = 1;
    }
  }
  for (n = 0; n < 20; n++) {
    if (numba == bottom[n]) {
      isBottom = 1;
    }
  }
  if (main[numba + 1] == main[numba] && isHead != 1) {
    return true;
  }
  if (main[numba + 10] == main[numba]) {
    return true;
  }
  if (main[numba - 1] == main[numba] && isBottom != 1) {
    return true;
  }
  if (main[numba - 10] == main[numba]) {
    return true;
  }
  return false;
}

//	Slides all non-0 balls down the column
//	and places the zeroed balls at the top
//	of each column.
//	If all balls in a column are marked with
//	a 0, all subsequent columns are moved left
//	and the last column is zeroed out.

function slideBalls() {
  change = 0;
  for (i = 0; i < 15; i++) {
    blankCount = 0;
    column = new Array();
    newColumn = new Array();
    for (c = 0; c < 10; c++) {
      column[c] = main[c + change];
    }
    for (c = 0; c < 10; c++) {
      if (column[c] == 0) {
        blankCount++;
        newColumn[10-blankCount] = 0;
      }
      else {
        newColumn[c - blankCount] = column[c];
      }
    }
    for (c = 0; c < 10; c++) {
      main[c + change] = newColumn[c];
    }
    if (blankCount == 10) {
      for (c = change; c < 150; c++) {
        main[c] = main[c + 10];
      }
      for (c = 140; c < 150; c++) {
        main[c] = 0;
      }
      change -= 10;
    }
    change += 10;
  }
}

//	Draws the balls on the game board based
//	on the values of the "main" Array.
//	0=blank  1=red  2=yellow  3=blue

function startUp() {
  document.scores.show.value = 0;
  for (i = 0; i < main.length; i++) {
    crayon = main[i];
    document["img" + i].src = eval("off" + crayon + ".src");
  }
}

function seed(reset){
  if(reset){
  	total = 0;
		winner = 0;
    document.scores.show.value = 0;
    document.scores.round.value = 0;
  }

  main = new Array();
  for (i = 0; i < 150; i++) {
      main[i] = random();
  }
  for (i = 0; i < main.length; i++) {
    crayon = main[i];
    document["img" + i].src = eval("off" + crayon + ".src");
  }
}

//	Take the ball which was clicked and
//	finds all connected balls of the same
//	color with findAdjacent2().

function findAdjacent(numba) {
  adj = new Array();
  adj[0] = numba;
  i = 0;
  c = 0;
  findAdjacent2(adj[c]);
}

//	Rolls through the "adj" Array and adds adjacent balls of
//	the same color to the "adj" Array.

//	Checks in this order: up, right, down, left
//	up=+1  right=+10  down=-1  left=-10.

//	isBottom and isHead checks to see if the ball
//	in question is on the top row or the bottom row.
//	If the ball in question is on the bottom row, the
//	down(-1) check is disabled, if it is on the top row
//	up(+1) is disabled.

//	Uses isAdjacent() to check whether or not the ball
//	in question is allready included in the "adj" Array.
//	Does not add the ball to the array if isAdjacent() returns
//	false.

function findAdjacent2(numba) {
  isBottom = 0;
  isHead = 0;
  for (n = 0; n < 20; n++) {
    if (numba == head[n]) {
      isHead = 1;
    }
  }
  for (n = 0; n < 20; n++) {
    if (numba == bottom[n]) {
      isBottom = 1;
    }
  }
  if (main[numba+1] == main[numba] && isHead != 1 && isAdjacent(numba+1)) {
    i++;
    adj[i] = numba + 1;
  }
  if (main[numba+10] == main[numba] && isAdjacent(numba+10)) {
    i++;
    adj[i] = numba + 10;
  }
  if (main[numba-1] == main[numba] && isBottom != 1 && isAdjacent(numba-1)) {
    i++;
    adj[i] = numba - 1;
  }
  if (main[numba-10] == main[numba] && isAdjacent(numba-10)) {
    i++;
    adj[i] = numba - 10;
  }
  c++;
  if (c == adj.length) {
    blah = 500;
  }
  else {
    findAdjacent2(adj[c]);
  }
}

//	Rolls through the "adj" Array, if the ball
//	in question is allready counted returns false.

function isAdjacent(numba) {
  isAdj = 1
  for (n=0; n<adj.length; n++) {
    if (adj[n] == numba) {
      isAdj = 0
    }
  }
  if (isAdj == 1) {
    return true;
  }
  else {
    return false;
  }
}