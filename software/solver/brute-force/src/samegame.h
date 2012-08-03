#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#ifdef DMALLOC
#include <dmalloc.h>
#endif


extern unsigned short int area, col_count, row_count, solved;
extern unsigned short int* hittable_checked;

struct numberListNode {
    unsigned int value;
    struct numberListNode *next;
};

struct numberListWithSize {
    unsigned int length;
    struct numberListNode* numberlist;
};

struct poiterListNode {
    struct numberListNode* numberlist;
    struct poiterListNode* next;
};

struct pointerListWithSize {
    unsigned int length;
    struct poiterListNode* hitlistlist;
};




void printGameField(unsigned short int*);
void printHitListList(struct pointerListWithSize*);
struct numberListWithSize* checkHits(unsigned short int*, unsigned short int, unsigned short int, struct numberListWithSize*);
struct pointerListWithSize* possibleHits(unsigned short int*);
unsigned short int* hit(unsigned short int*, struct numberListNode*);
struct numberListNode* solve(unsigned short int*);
struct numberListNode* positionToGene(unsigned short int*, struct numberListNode*);
