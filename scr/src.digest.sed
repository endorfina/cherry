:i
s~(;%s*)import%s*%path%s*\{%s*\}~\1~g
s~(;%s*)import%s*(%path)%s*\{%s*(%path)%s*(,([^}]+))?\}~\1import \2/\3;import \2 {\5}~
ti
s~(;%s*)import%s*(%path\.hpp)~\1#include <\2>~g
s~(;%s*)import%s*(%path)~\1#include "\2.hpp"~g

/let/{
  s~let%s+mut%s+(%name)%s*:%s*([[:alpha:]][^=]*[[:alnum:]>])%s*=%s*([&*]*)~\2\3 \1 = ~g
  s~let%s+mut%s+(%name)%s*=%s*([&*]*)~auto\2 \1 = ~g
  s~::let%s+(%name)%s*=%s*([&*]*)~static constexpr auto\2 \1 = ~g
  s~:let%s+(%name)%s*=%s*([&*]*)~constexpr auto\2 \1 = ~g
  s~let%s+(%name)%s*:%s*([[:alpha:]][^=]*[[:alnum:]>])%s*=%s*([&*]*)~const \2\3 \1 = ~g
  s~let%s+(%name)%s*=%s*([&*]*)~const auto\2 \1 = ~g
}

/fn%s+%type%s*\(.*:.*\)/{
  :a
  s~fn%s+(%type)\((.*,%s*)?%s*(%name)%s*:%s*([&*]*)%s*mut%s*([[:alpha:]][^,()]+)~fn \1(\4\7\6 \5~
  ta
  s~fn%s+(%type)\((.*,%s*)?%s*(%name)%s*:%s*([&*]*)%s*([[:alpha:]][^,()]+)~fn \1(\4const \7\6 \5~
  ta
}

/\|[^|]*\|%s*(->|\{)/{
  :b
  s~\|(.*,%s*)?%s*(%name)%s*:%s*([&*]*)%s*mut%s*([[:alpha:]][^,|]+)([^|]*\|%s*(->|\{))~|\1\4\3 \2\5~
  tb
  s~\|(.*,%s*)?%s*(%name)%s*:%s*([&*]*)%s*([[:alpha:]][^,|]+)([^|]*\|%s*(->|\{))~|\1const \4\3 \2\5~
  tb
  s~\|([^|]*)\|%s*(->|\{)~[](\1) \2~g
}

s~\)%s*->%s*([&*]+)%s*mut%s*([[:alpha:]][^{]*[_>[:alnum:]])~) -> \2\1~
s~\)%s*->%s*([&*]+)%s*([[:alpha:]][^{]*[_>[:alnum:]])~) -> const \2\1~

s~:([[:punct:]]?fn%s+%type%s*\([^}{]*\))~constexpr \1~
s~\&(fn%s+%type%s*\([^}{]*\))~\1 const~
s~fn%s+(%type%s*\([^}{]*\)(%s*%name)*)%s*->~auto \1 noexcept ->~
s~fn%s+(%type%s*\([^}{]*\)(%s*%name)*)~void \1 noexcept~

s/~~([^~]+)%s+as%s+<(\*+)%s*([[:alpha:]][^>]*)>/reinterpret_cast<\3\2>(\1)/g
s/~~([^~]+)%s+as%s+(\*+)%s*(%type)/reinterpret_cast<\3\2>(\1)/g

s/~([^~]+)%s+as%s+<([&*]*)%s*([[:alpha:]][^>]*)>/static_cast<\3\2>(\1)/g
s/~([^~]+)%s+as%s+([&*]*)%s*(%type)/static_cast<\3\2>(\1)/g

p
