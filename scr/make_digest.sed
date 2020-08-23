s~%type~(%name::)*(%name)~g

s~%name~[[:alpha:]][_<>[:alnum:]]*~g

s~%&~[\&*;[:space:]]~g

s~%s~[;[:space:]]~g

s~%path~[[:alnum:]][[:alnum:]/._-]*~g

s~^[[:space:]]*#%[[:space:]]*~~

s~%^~[^[:alnum:]]~g

/^[[:space:]]*$/d
