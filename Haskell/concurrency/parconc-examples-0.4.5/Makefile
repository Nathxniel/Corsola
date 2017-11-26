C=ghc
FLAGS=-O2 -threaded

.PHONY: softclean clean

strat:
	$(C) $(FLAGS) strat.hs

clean:
	rm -f *.o *.hi strat

softclean:
	rm -f *.o *.hi
