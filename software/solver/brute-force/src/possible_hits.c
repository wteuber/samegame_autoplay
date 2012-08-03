#include "samegame.h"

struct pointerListWithSize* possibleHits(unsigned short int* game_field) {
    unsigned short int col = 0, row = 0;
    struct numberListWithSize* tileList = NULL;
    struct pointerListWithSize* possible_hits = malloc(sizeof (struct pointerListWithSize));

    possible_hits->hitlistlist = NULL;
    possible_hits->length = 0;
    memset(hittable_checked, 0, sizeof (unsigned short int) * col_count * row_count);

    for (col = 0; col < col_count; col++) {
        for (row = 0; row < row_count; row++) {
            if (!hittable_checked[row_count * col + row] && game_field[row_count * col + row] > 0) {
                tileList = malloc(sizeof (struct numberListWithSize));
                tileList->length = 0;
                tileList->numberlist = NULL;
                tileList = checkHits(game_field, col, row, tileList);

                if (tileList->length < area) {
                    while (tileList->numberlist != NULL) {
                        struct numberListNode* tmp = tileList->numberlist->next;
                        free(tileList->numberlist);
                        tileList->numberlist = tmp;
                    }
                } else {
                    struct poiterListNode* tmp = possible_hits->hitlistlist;
                    possible_hits->hitlistlist = malloc(sizeof (struct poiterListNode));
                    possible_hits->hitlistlist->next = tmp;
                    possible_hits->hitlistlist->numberlist = tileList->numberlist;

                    possible_hits->length++;
                }
                free(tileList);
                tileList = NULL;
            }
        }
    }
    return possible_hits;
}