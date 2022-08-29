#include <core.p4>
#include <ubpf_model.p4>

header header_one {
    bit<8> type;
    bit<8> data;
}

header header_two {
    bit<8>  type;
    bit<16> data;
}

header header_four {
    bit<8>  type;
    bit<32> data;
}

struct Headers_t {
    header_one  one;
    header_two  two;
    header_four four;
}

struct metadata {
}

parser prs(packet_in p, out Headers_t headers, inout metadata meta, inout standard_metadata std_meta) {
    @name("prs.tmp_0") bit<8> tmp_0;
    state stateOutOfBound {
        verify(false, error.StackOutOfBounds);
        transition reject;
    }
    state parse_four {
        p.extract<header_four>(headers.four);
        transition parse_headers1;
    }
    state parse_four1 {
        p.extract<header_four>(headers.four);
        transition parse_headers2;
    }
    state parse_four2 {
        p.extract<header_four>(headers.four);
        transition parse_headers4;
    }
    state parse_four3 {
        p.extract<header_four>(headers.four);
        transition parse_headers7;
    }
    state parse_headers {
        tmp_0 = p.lookahead<bit<8>>();
        transition select(tmp_0) {
            8w1: parse_one;
            8w2: parse_two;
            8w4: parse_four;
            default: accept;
        }
    }
    state parse_headers1 {
        tmp_0 = p.lookahead<bit<8>>();
        transition select(tmp_0) {
            8w1: parse_one;
            8w2: parse_two;
            8w4: parse_four1;
            default: accept;
        }
    }
    state parse_headers2 {
        transition stateOutOfBound;
    }
    state parse_headers3 {
        tmp_0 = p.lookahead<bit<8>>();
        transition select(tmp_0) {
            8w1: parse_one;
            8w2: parse_two1;
            8w4: parse_four2;
            default: accept;
        }
    }
    state parse_headers4 {
        transition stateOutOfBound;
    }
    state parse_headers5 {
        transition stateOutOfBound;
    }
    state parse_headers6 {
        tmp_0 = p.lookahead<bit<8>>();
        transition select(tmp_0) {
            8w1: parse_one1;
            8w2: parse_two2;
            8w4: parse_four3;
            default: accept;
        }
    }
    state parse_headers7 {
        transition stateOutOfBound;
    }
    state parse_headers8 {
        transition stateOutOfBound;
    }
    state parse_headers9 {
        transition stateOutOfBound;
    }
    state parse_one {
        p.extract<header_one>(headers.one);
        transition parse_headers6;
    }
    state parse_one1 {
        p.extract<header_one>(headers.one);
        transition parse_headers9;
    }
    state parse_two {
        p.extract<header_two>(headers.two);
        transition parse_headers3;
    }
    state parse_two1 {
        p.extract<header_two>(headers.two);
        transition parse_headers5;
    }
    state parse_two2 {
        p.extract<header_two>(headers.two);
        transition parse_headers8;
    }
    state start {
        transition parse_headers;
    }
}

control pipe(inout Headers_t headers, inout metadata meta, inout standard_metadata std_meta) {
    apply {
    }
}

control dprs(packet_out packet, in Headers_t headers) {
    @hidden action lookahead_ubpf61() {
        packet.emit<header_one>(headers.one);
        packet.emit<header_two>(headers.two);
        packet.emit<header_four>(headers.four);
    }
    @hidden table tbl_lookahead_ubpf61 {
        actions = {
            lookahead_ubpf61();
        }
        const default_action = lookahead_ubpf61();
    }
    apply {
        tbl_lookahead_ubpf61.apply();
    }
}

ubpf<Headers_t, metadata>(prs(), pipe(), dprs()) main;

