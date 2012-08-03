same_game_app = sg_bt_solver
clean_up = true
dmalloc = false
src = ./src/
bin = ./bin/
lib = ./lib/
CC = gcc

ifeq ($(dmalloc),true)
  opts = -DDMALLOC 
  libs = ./lib/libdmalloc.a
endif

objects = $(bin)$(same_game_app).o $(bin)sgprint.o $(bin)possible_hits.o $(bin)check_hits.o $(bin)hit.o $(bin)solve.o $(bin)position_to_gene.o

$(bin)$(same_game_app) : $(objects)
	$(CC) -o $(bin)$(same_game_app) $(objects) $(libs)
ifeq ($(clean_up),true)
	rm -f $(objects) *.stackdump
endif
ifeq ($(dmalloc),true)
	@echo
	@echo "Set up dmalloc... e.g. RUN:"
	@echo "  dmalloc high -i 100 -l dmalloc%t.log"
endif
$(bin)$(same_game_app).o : $(src)$(same_game_app).c
	$(CC) $(opts)-c $(src)$(same_game_app).c -o $(bin)$(same_game_app).o
$(bin)sgprint.o : $(src)sgprint.c
	$(CC) $(opts)-c $(src)sgprint.c -o $(bin)sgprint.o
$(bin)possible_hits.o : $(src)possible_hits.c
	$(CC) $(opts)-c $(src)possible_hits.c -o $(bin)possible_hits.o
$(bin)check_hits.o : $(src)check_hits.c
	$(CC) $(opts)-c $(src)check_hits.c -o $(bin)check_hits.o
$(bin)hit.o : $(src)hit.c
	$(CC) $(opts)-c $(src)hit.c -o $(bin)hit.o
$(bin)solve.o : $(src)solve.c
	$(CC) $(opts)-c $(src)solve.c -o $(bin)solve.o
$(bin)position_to_gene.o : $(src)position_to_gene.c
	$(CC) $(opts)-c $(src)position_to_gene.c -o $(bin)position_to_gene.o
clean :
	rm -f $(bin)$(same_game_app) $(objects) *.stackdump