make_digest:
	./cherry.sh --regen scr

test: make_digest
	@rm -rf test/output
	find test -name '*.?ry' -exec ./cherry.sh -f scr/digest.sed -v --out test/output '{}' +

ut: make_digest
	./ut.sh test/uts

.PHONY: make_digest test ut
