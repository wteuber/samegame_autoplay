#include "samegame.h"

struct numberListNode* solve(unsigned short int* game_field) {
  struct numberListNode* solution = NULL, *tmp_nl = NULL;
  struct pointerListWithSize* possible_hits = NULL;
  struct poiterListNode* tmp_hll = NULL;
  unsigned short int* game_field_after_hit = NULL;

  /****************************/
  /* Processing Possible Hits */
  /****************************/
  possible_hits = possibleHits(game_field);

  /*************************/
  /* Checking for Solution */
  /*************************/
  if (possible_hits->length == 0 && game_field[0] != 0) {
    /*************************************/
    /* recursion tree leaf, not solvable */
    /*************************************/
    while (possible_hits->hitlistlist != NULL) {
      tmp_hll = possible_hits->hitlistlist->next;
      while (possible_hits->hitlistlist->numberlist != NULL) {
        tmp_nl = possible_hits->hitlistlist->numberlist->next;
        free(possible_hits->hitlistlist->numberlist);
        possible_hits->hitlistlist->numberlist = tmp_nl;
      }
      free(possible_hits->hitlistlist);
      possible_hits->hitlistlist = tmp_hll;
    }
    free(possible_hits);
    possible_hits = NULL;

  } else {
    /***************************************/
    /* recursion tree node, not solved yet */
    /***************************************/
    while (possible_hits->hitlistlist != NULL) {
      tmp_hll = possible_hits->hitlistlist->next;

      game_field_after_hit = hit(game_field, possible_hits->hitlistlist->numberlist);

      solution = solve(game_field_after_hit);

      if (solution == NULL && game_field_after_hit[0] != 0) {
        /**************/
        /* not solved */
        /**************/
        while (possible_hits->hitlistlist->numberlist != NULL) {
          tmp_nl = possible_hits->hitlistlist->numberlist->next;
          free(possible_hits->hitlistlist->numberlist);
          possible_hits->hitlistlist->numberlist = tmp_nl;
        }
        free(possible_hits->hitlistlist);
        possible_hits->hitlistlist = tmp_hll;

        free(game_field_after_hit);
        game_field_after_hit = NULL;
      } else {
        /**********/
        /* solved */
        /**********/
        struct numberListNode *tmp = solution;
        solution = malloc(sizeof (struct numberListNode));
        solution->next = tmp;
        solution->value = possible_hits->hitlistlist->numberlist->value;

        while (possible_hits->hitlistlist->numberlist != NULL) {
          tmp_nl = possible_hits->hitlistlist->numberlist->next;
          free(possible_hits->hitlistlist->numberlist);
          possible_hits->hitlistlist->numberlist = tmp_nl;
        }
        free(possible_hits->hitlistlist);
        possible_hits->hitlistlist = tmp_hll;

        free(game_field_after_hit);
        game_field_after_hit = NULL;

        return solution;
      }
    }
    free(possible_hits);
    possible_hits = NULL;
  }
  return NULL;
}