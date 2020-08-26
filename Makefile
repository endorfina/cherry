script_out_file=scr/digest.sed
script_in_file=scr/src.digest.sed
script_make_script=scr/make_digest.sed

make_digest:
	@test -r "${script_out_file}" \
	    -a "${script_out_file}" -nt "${script_in_file}" \
	    -a "${script_out_file}" -nt "${script_make_script}" \
	    || sed -E -f "${script_make_script}" "${script_in_file}" > "${script_out_file}"

test: make_digest
	@rm -rf test/output
	find test -name '*.?ry' -exec ./cherry.sh -f scr/digest.sed -v --out test/output '{}' +

ut: make_digest
	./ut.sh test/uts

.PHONY: make_digest test
