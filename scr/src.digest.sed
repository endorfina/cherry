/let/{
  s~let%s+mut([&*;[:space:]]+)(%name)%s*=~auto\1\2 =~g
  s~let([&*;[:space:]]+)(%name)%s*=~const auto\1\2 =~g
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

s~\+(=?fn%s+%type%s*\([^}{]*\))~constexpr \1~
s~=(fn%s+%type%s*\([^}{]*\))~\1 const~
s~fn%s+(%type%s*\([^}{]*\)(%s*%name)*)%s*->~auto \1 noexcept ->~
s~fn%s+(%type%s*\([^}{]*\)(%s*%name)*)~void \1 noexcept~

s/~~([^~]+)%s+as%s+<(\*+)%s*([[:alpha:]][^>]*)>/reinterpret_cast<\3\2>(\1)/g
s/~~([^~]+)%s+as%s+(\*+)%s*(%type)/reinterpret_cast<\3\2>(\1)/g

s/~([^~]+)%s+as%s+<([&*]*)%s*([[:alpha:]][^>]*)>/static_cast<\3\2>(\1)/g
s/~([^~]+)%s+as%s+([&*]*)%s*(%type)/static_cast<\3\2>(\1)/g

p
