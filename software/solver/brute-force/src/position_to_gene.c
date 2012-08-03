#include "samegame.h"

struct numberListNode* positionToGene(unsigned short int* game_field, struct numberListNode* solution) {
    unsigned int i = 0;
    struct pointerListWithSize* possible_hits = NULL;

    printf("[");
    while (solution != NULL) {
        possible_hits = possibleHits(game_field);


/*
        printf("\n");
        printHitListList(possible_hits);
        printf("[%d,%d]\n", solution->value / row_count, solution->value % row_count);
*/



        i = 0;
        while (possible_hits->hitlistlist->numberlist->value != solution->value) {
            i++;
            possible_hits->hitlistlist = possible_hits->hitlistlist->next;
        }
        printf("%d", possible_hits->length - i);


        game_field = hit(game_field, possible_hits->hitlistlist->numberlist);
        solution = solution->next;
        if (solution != NULL) {
            printf(",");
        }
    }
    printf("]\n");
}