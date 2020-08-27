/%res_/{
  h

  /%res_cexpr/{
    s~%res_cexpr[[:space:]]?~~g
    s~%const_let~let~g
    x

    s~%res_cexpr~ constexpr~g
    s~%const_let~:let~g
    s~%opt_mut(%s[*+])?~~g
    s~%res_const[[:space:]]?~~g
    G
  }

  /%res_const/{
    s~%opt_mut~mut~g
    s~%res_const[[:space:]]?~~g
    G
  }

  s~%opt_mut(%s[*+])?~~g
  s~%res_const~const~g
}

s~%type~(%name::)*(%name)~g

s~%ftype~[[:alpha:]][^=\{\(]*[[:alnum:]>]~g

s~%name~[[:alpha:]][_<>[:alnum:]]*~g

s~%&~[\&*;[:space:]]~g

s~%s~[;[:space:]]~g

s~%path~[[:alnum:]][[:alnum:]/._-]*~g

s~^[[:space:]]*#%[[:space:]]*~~

s~%^~[^[:alnum:]]~g

/^[[:space:]]*$/d
