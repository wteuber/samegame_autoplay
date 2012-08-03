CC = /cygdrive/c/Program\ Files/AutoIt3/Aut2Exe/Aut2exe.exe

sdir = ./src/
sext = .au3
idir = ./ico/
iext = .ico
bdir = ./bin/
bext = .exe

sg = samegame

bez = bezumie_same
bri = bricks_breaking
cub = cube_crash
hay = haynes_same
knu = knugie_same
cur = _init_cursor

otp = /console /comp 4

all:
ifneq ("$(wildcard $(sdir)$(bez)$(cur)$(sext))","")
ifneq ("$(wildcard $(idir)$(bez)$(iext))","")
	@echo "[$(bez)] using custom icon: $(idir)$(bez)$(iext)"
	$(CC) /in $(sdir)$(bez)$(cur)$(sext) /out $(bdir)$(bez)$(cur)$(bext) /icon $(idir)$(bez)$(iext) $(otp)
else
	@echo "[$(bez)] using default icon"
	$(CC) /in $(sdir)$(bez)$(cur)$(sext) /out $(bdir)$(bez)$(cur)$(bext) $(otp)
endif
else
	@echo "[$(bez)] file not found: $(sdir)$(bez)$(cur)$(sext)"
endif

ifneq ("$(wildcard $(sdir)$(bri)$(cur)$(sext))","")
ifneq ("$(wildcard $(idir)$(bri)$(iext))","")
	@echo "[$(bri)] using custom icon: $(idir)$(bri)$(iext)"
	$(CC) /in $(sdir)$(bri)$(cur)$(sext) /out $(bdir)$(bri)$(cur)$(bext) /icon $(idir)$(bri)$(iext) $(otp)
else
	@echo "[$(bri)] using default icon"
	$(CC) /in $(sdir)$(bri)$(cur)$(sext) /out $(bdir)$(bri)$(cur)$(bext) $(otp)
endif
else
	@echo "[$(bri)] file not found: $(sdir)$(bri)$(cur)$(sext)"
endif

ifneq ("$(wildcard $(sdir)$(cub)$(cur)$(sext))","")
ifneq ("$(wildcard $(idir)$(cub)$(iext))","")
	@echo "[$(cub)] using custom icon: $(idir)$(cub)$(iext)"
	$(CC) /in $(sdir)$(cub)$(cur)$(sext) /out $(bdir)$(cub)$(cur)$(bext) /icon $(idir)$(cub)$(iext) $(otp)
else
	@echo "[$(cub)] using default icon"
	$(CC) /in $(sdir)$(cub)$(cur)$(sext) /out $(bdir)$(cub)$(cur)$(bext) $(otp)
endif
else
	@echo "[$(cub)] file not found: $(sdir)$(cub)$(cur)$(sext)"
endif

ifneq ("$(wildcard $(sdir)$(knu)$(cur)$(sext))","")
ifneq ("$(wildcard $(idir)$(knu)$(iext))","")
	@echo "[$(knu)] using custom icon: $(idir)$(knu)$(iext)"
	$(CC) /in $(sdir)$(knu)$(cur)$(sext) /out $(bdir)$(knu)$(cur)$(bext) /icon $(idir)$(knu)$(iext) $(otp)
else
	@echo "[$(knu)] using default icon"
	$(CC) /in $(sdir)$(knu)$(cur)$(sext) /out $(bdir)$(knu)$(cur)$(bext) $(otp)
endif
else
	@echo "[$(knu)] file not found: $(sdir)$(knu)$(cur)$(sext)"
endif

ifneq ("$(wildcard $(sdir)$(hay)$(cur)$(sext))","")
ifneq ("$(wildcard $(idir)$(hay)$(iext))","")
	@echo "[$(hay)] using custom icon: $(idir)$(hay)$(iext)"
	$(CC) /in $(sdir)$(hay)$(cur)$(sext) /out $(bdir)$(hay)$(cur)$(bext) /icon $(idir)$(hay)$(iext) $(otp)
else
	@echo "[$(hay)] using default icon"
	$(CC) /in $(sdir)$(hay)$(cur)$(sext) /out $(bdir)$(hay)$(cur)$(bext) $(otp)
endif
else
	@echo "[$(hay)] file not found: $(sdir)$(hay)$(cur)$(sext)"
endif

ifneq ("$(wildcard $(sdir)$(sg)$(sext))","")
ifneq ("$(wildcard $(idir)$(sg)$(iext))","")
	@echo "[$(sg)] using custom icon: $(idir)$(sg)$(iext)"
	$(CC) /in $(sdir)$(sg)$(sext) /out $(bdir)$(sg)$(bext) /icon $(idir)$(sg)$(iext) $(otp)
else
	@echo "[$(sg)] using default icon"
	$(CC) /in $(sdir)$(sg)$(sext) /out $(bdir)$(sg)$(bext) $(otp)
endif
else
	@echo "[$(sg)] file not found: $(sdir)$(sg)$(sext)"
endif