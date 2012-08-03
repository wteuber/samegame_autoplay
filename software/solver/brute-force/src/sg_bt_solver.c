#include "samegame.h"

unsigned short int area = 2, col_count = 0, row_count = 0;
unsigned int rec_count = 0, level = 0;
unsigned short int* hittable_checked = NULL;

int main(int argc, char *argv[], char *envp[]) {
#ifdef DMALLOC
  /*
   * Use
   *   gcc -DDMALLOC ./src/*.c ./lib/libdmalloc.a  -o ./bin/sg_bt_solver
   * to compile and link sg_bt_solver with dmalloc.
   *
   * Get environment variable DMALLOC_OPTIONS and pass the settings string
   * on to dmalloc_debug_setup to setup the dmalloc debugging flags.
   */
  dmalloc_debug_setup(getenv("DMALLOC_OPTIONS"));
#endif

  char *input_string, c;
  unsigned short col = 0, row = 0, i = 0, val = 0;
  unsigned int commas = 0, brackets = 0;
  unsigned short int* game_field = NULL;
  struct numberListNode* solution = NULL;

  /**************/
  /* Area Input */
  /**************/
  input_string = argv[1];
  if ((input_string[0] - '0' >= 0) && (input_string[0] - '0' <= 9)) {
    area = atoi(&input_string[0]);
  }

  /********************/
  /* Game Field Input */
  /********************/
  input_string = argv[2];
  while (c = input_string[i++]) {
    brackets += (c == ']');
    commas += (c == ',');
  }
  col_count = (brackets - 1);
  row_count = (commas - (col_count - 1)) / col_count + 1;

  game_field = malloc(sizeof (unsigned short int) * col_count * row_count);
  i = 0;
  val = 0;
  col = 0;
  row = 0;
  while (c = input_string[i++]) {
    val = c - '0';
    if ((val >= 0) && (val <= 9)) {
      game_field[row_count * col + row] = (unsigned short int) (val);
    } else if (c == '[') {
      row = 0;
    } else if (c == ',') {
      row++;
    } else if (c == ']') {
      col++;
    } else {
      printf("Error: undefined color: '%c'\n", c);
      exit(0);
    }
  }

  printf("Area:\n %d\n\n", area);
  printf("Game Field:\n");
  printGameField(game_field);
  printf("\n");

  hittable_checked = malloc(sizeof (unsigned short int) * col_count * row_count);
  solution = solve(game_field);



  /**********/
  /* Output */
  /**********/
  if (solution != NULL) {
    printf("SOLUTION:\n");
    solution = positionToGene(game_field, solution);


    /*
            printf("[");
            while (solution != NULL) {
                printf("[%d,%d]", solution->value / row_count, solution->value % row_count);
                solution = solution->next;
                if (solution != NULL) {
                    printf(", ");
                }
            }
            printf("]\n");
     */

    /*
            while (solution != NULL) {
                struct numberListNode* tmp = solution->next;
                free(solution);
                solution = tmp;
            }
     */
  } else {
    printf("No Solution found!\n");
    return (EXIT_FAILURE);
  }

  return (EXIT_SUCCESS);
}