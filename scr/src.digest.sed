/import%s/{
  :i
  s~(^|;)%s*import%s*(%path%s*)?\{%s*\}~\1~g
  s~(^|;)%s*import%s*\{%s*(%path)%s*(,([^}]+))?\}~\1import \2;import {\4}~
  ti
  s~(^|;)%s*import%s*(%path)%s*\{%s*(%path)%s*(,([^}]+))?\}~\1import \2/\3;import \2 {\5}~
  ti
  s~(^|;)%s*import%s*(%path\.hp*)~\1#include <\2>~g
  s~(^|;)%s*import%s*(%path)~\1#include "\2.hpp"~g
}

:c
s~(<[^>()]+),([^>()]+>)~\1[++]comma\2~
tc

/fn%s+%type%s*\(.*:.*\)/{
  :a
  s~fn%s+(%type)\((.*,%s*)?%s*(%name)%s*:%s*([&*]*)%s*%opt_mut%s*([[:alpha:]][^,()]+)~fn \1(\4%res_const \7\6 \5~;ta
}

/\|[^|]*\|%s*(->|\{)/{
  :b
  s~\|(.*,%s*)?%s*(%name)%s*:%s*([&*]*)%s*%opt_mut%s*([[:alpha:]][^,|]+)([^|]*\|%s*(->|\{))~|\1%res_const \4\3 \2\5~;tb
  s~(\[(.*)\]%s*)?\|([^|]*)\|%s*(->|\{)~[\2](\3) \4~g
}

s~\[\+\+\]comma~,~g

s~\)%s*->%s*([&*]+)%s*%opt_mut%s*([[:alpha:]][^{]*[_>[:alnum:]])~) -> %res_const \2\1~

s~:([[:punct:]]?fn%s+%type%s*\([^}{]*\))~constexpr \1~
s~\&(fn%s+%type%s*\([^}{]*\))~\1 const~
s~fn%s+(%type%s*\([^}{]*\)(%s*%name)*)%s*->~auto \1 noexcept ->~
s~fn%s+(%type%s*\([^}{]*\)(%s*%name)*)~void \1 noexcept~

/let%s/{
  s~::let%s+~static :let ~g
  s~%const_let%s+%opt_mut%s+(%name)%s*:%s*(%ftype)%s*(\[[^[:punct:]]*\])?%s*=%s*([&*]*)~%res_cexpr %res_const \2\4 \1\3 = ~g
  s~%const_let%s+%opt_mut%s+(%name)%s*:%s*(%ftype)%s*(\[[^[:punct:]]*\])?%s*\{~%res_cexpr %res_const \2 \1\3 {~g
  s~%const_let%s+%opt_mut%s+(%name)%s*=%s*([&*]*)~%res_cexpr %res_const auto\2 \1 = ~g
}

p
