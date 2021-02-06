.PHONY: all
all: indirect.s indirect.thunk.s

indirect.s: indirect.c
	gcc -S indirect.c -o indirect.s

indirect.thunk.s: indirect.c
	gcc -S indirect.c -mindirect-branch=thunk -o indirect.thunk.s

.PHONY: clean
	rm -rf indirect.s indirect.thunk.s
