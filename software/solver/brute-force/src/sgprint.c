#include "samegame.h"

void printGameField(unsigned short int* matrix) {
    unsigned short int col = 0, row = 0;

    printf(" ");
    for (row = 0; row < row_count; row++) {
        for (col = 0; col < col_count; col++) {
            printf("%d", matrix[(row_count * col) + (row_count - 1 - row)]);
            if (col != col_count - 1) printf(" ");
        }
        if (row != row_count - 1) {
            printf("\n ");
        }
    }
    printf("\n");
    return;
}

void printHitListList(struct pointerListWithSize* p1ossible_hits) {
    unsigned int i = 0, possible_hit_count = p1ossible_hits->length;
    struct poiterListNode* current_hll = p1ossible_hits->hitlistlist;
    struct numberListNode* current_nl = NULL;

    printf("%d Possible Hits (area>=%d) :\n", possible_hit_count, area);
    if (possible_hit_count != 0) {
        while (current_hll != NULL) {
            printf("%4d: {", ++i);
            current_nl = current_hll->numberlist;
            while (current_nl != NULL) {
                printf("{%d,%d}", current_nl->value / row_count, current_nl->value % row_count);
                current_nl = current_nl->next;
                if (current_nl != NULL) {
                    printf(", ");
                }
            }
            printf("}\n");
            current_hll = current_hll->next;
        }
    }
    return;
}