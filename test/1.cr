let mut jk = &1;

let mut a = 2;

&fn bar(damn: *void) -> &std::string;

fn compare_strings(lhs: &std::string, rhs: &std::string) -> bool
{
    return lhs == rhs;
}

template <typename Char>
:&fn check(c: Char) -> bool {
    return ~c as uint8_t >> 6 == 0x2;
}

template <typename CharIt>
:fn sequence_length(it: CharIt) -> unsigned short
{
    let byte = ~*it as uint8_t;

    if (byte < 0x80) return 1;

    else if ((byte >> 5) == 0x6) return 2;

    else if ((byte >> 4) == 0xe) return 3;

    else if ((byte >> 3) == 0x1e) return 4;

    else if ((byte >> 2) == 0x3e) return 5;

    else if ((byte >> 1) == 0x7e) return 6;

    return 0;
}


