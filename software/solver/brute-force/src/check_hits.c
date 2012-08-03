#include "samegame.h"

struct numberListWithSize* checkHits(unsigned short int* game_field, unsigned short int col, unsigned short int row, struct numberListWithSize* tileList) {

    struct numberListNode* nlnTemp = tileList->numberlist;
    tileList->numberlist = malloc(sizeof (struct numberListNode));
    tileList->numberlist->value = row_count * col + row;
    tileList->numberlist->next = nlnTemp;
    tileList->length++;

    hittable_checked[row_count * col + row] = 1;

    /*********/
    /* North */
    /*********/
    if (((row + 1) < row_count) &&
            (!hittable_checked[row_count * col + (row + 1)]) &&
            (game_field[row_count * col + row] == game_field[row_count * col + row + 1])) {
        checkHits(game_field, col, row + 1, tileList);
    }

    /********/
    /* East */
    /********/
    if (((col + 1) < col_count) &&
            (!hittable_checked[row_count * (col + 1) + row]) &&
            (game_field[row_count * col + row] == game_field[row_count * (col + 1) + row])) {
        checkHits(game_field, col + 1, row, tileList);
    }

    /*********/
    /* South */
    /*********/
    if (((row - 1) >= 0) &&
            (!hittable_checked[row_count * col + row - 1]) &&
            (game_field[row_count * col + row] == game_field[row_count * col + row - 1])) {
        checkHits(game_field, col, row - 1, tileList);
    }

    /********/
    /* West */
    /********/
    if (((col - 1) >= 0) &&
            (!hittable_checked[row_count * (col - 1) + row]) &&
            (game_field[row_count * col + row] == game_field[row_count * (col - 1) + row])) {
        checkHits(game_field, col - 1, row, tileList);
    }

    return tileList;
}
