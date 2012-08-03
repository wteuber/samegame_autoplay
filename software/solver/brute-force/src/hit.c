#include "samegame.h"

unsigned short int* hit(unsigned short int* matrix, struct numberListNode* hitlist) {
    //    printf("HIT (%2d,%2d):\n", hitlist->value / row_count, hitlist->value % row_count);
    struct numberListNode* current_nl = hitlist;
    unsigned short int col = 0, row = 0, involved_cols[col_count];
    memset(involved_cols, 0, sizeof (unsigned short int) * col_count);
    unsigned short int* res_matrix = malloc(sizeof (unsigned short int) * col_count * row_count);
    memcpy(res_matrix, matrix, sizeof (unsigned short int) * col_count * row_count);

    /**********/
    /* Remove */
    /**********/
    while (current_nl != NULL) {
        res_matrix[current_nl->value] = 0;
        involved_cols[current_nl->value / row_count] = 1;
        current_nl = current_nl->next;
    }

    /*************/
    /* Normalize */
    /*************/
    unsigned short int go_on = 1, dst = 0, src = 0;
    for (col = col_count; (col-- > 0);) {
        if (involved_cols[col]) {
            row = row_count;
            go_on = 1;
            while (row != 0) {
                while ((row-- > 0) && (go_on || (res_matrix[row_count * col + row]))) {
                    if (res_matrix[row_count * col + row]) go_on = 0;
                }
                row++;
                if (row == 0 && go_on == 1) {
                    memmove(&res_matrix[row_count * col], &res_matrix[row_count * (col + 1)], row_count * (col_count - (col + 1)) * sizeof (unsigned short int));
                    memset(&res_matrix[row_count * (col_count - 1) ], 0, (row_count) * sizeof (unsigned short int));
                } else {
                    src = row;
                    while ((row-- > 0) && (!res_matrix[row_count * col + row]));
                    row++;
                    dst = row;
                    memmove(&res_matrix[row_count * col + dst], &res_matrix[row_count * col + src], (row_count - src) * sizeof (unsigned short int));
                    memset(&res_matrix[row_count * col + row_count - src + dst], 0, (src - dst) * sizeof (unsigned short int));
                }
            }
        }
    }
    //    printGameField(res_matrix);
    return res_matrix;
}