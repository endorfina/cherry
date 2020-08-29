make_digest:
	./cherry.sh --regen scr

examples: make_digest
	@rm -rf test/output
	find test -name '*.?ry' -exec ./cherry.sh -f scr/digest.sed -v --out test/output '{}' +

test: make_digest
	./ut.sh test/uts

.PHONY: make_digest examples test
