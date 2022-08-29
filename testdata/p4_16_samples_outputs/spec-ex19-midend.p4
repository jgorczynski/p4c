#include <core.p4>

header Mpls_h {
    bit<20> label;
    bit<3>  tc;
    bit<1>  bos;
    bit<8>  ttl;
}

header Tcp_option_end_h {
    bit<8> kind;
}

header Tcp_option_nop_h {
    bit<8> kind;
}

header Tcp_option_ss_h {
    bit<8>  kind;
    bit<32> maxSegmentSize;
}

header Tcp_option_s_h {
    bit<8>  kind;
    bit<24> scale;
}

header Tcp_option_sack_h {
    bit<8>      kind;
    bit<8>      length;
    varbit<256> sack;
}

header_union Tcp_option_h {
    Tcp_option_end_h  end;
    Tcp_option_nop_h  nop;
    Tcp_option_ss_h   ss;
    Tcp_option_s_h    s;
    Tcp_option_sack_h sack;
}

typedef Tcp_option_h[10] Tcp_option_stack;
struct Tcp_option_sack_top {
    bit<8> kind;
    bit<8> length;
}

parser Tcp_option_parser(packet_in b, out Tcp_option_stack vec) {
    @name("Tcp_option_parser.tmp_0") bit<8> tmp_0;
    bit<16> tmp_5;
    state stateOutOfBound {
        verify(false, error.StackOutOfBounds);
        transition reject;
    }
    state noMatch {
        verify(false, error.NoMatch);
        transition reject;
    }
    state parse_tcp_option_end {
        b.extract<Tcp_option_end_h>(vec[32w0].end);
        transition accept;
    }
    state parse_tcp_option_end1 {
        b.extract<Tcp_option_end_h>(vec[32w1].end);
        transition accept;
    }
    state parse_tcp_option_nop {
        b.extract<Tcp_option_nop_h>(vec[32w0].nop);
        transition start1;
    }
    state parse_tcp_option_nop1 {
        b.extract<Tcp_option_nop_h>(vec[32w1].nop);
        transition start2;
    }
    state parse_tcp_option_s {
        b.extract<Tcp_option_s_h>(vec[32w0].s);
        transition start1;
    }
    state parse_tcp_option_s1 {
        b.extract<Tcp_option_s_h>(vec[32w1].s);
        transition start2;
    }
    state parse_tcp_option_sack {
        tmp_5 = b.lookahead<bit<16>>();
        b.extract<Tcp_option_sack_h>(vec[32w0].sack, (bit<32>)((tmp_5[7:0] << 3) + 8w240));
        transition start1;
    }
    state parse_tcp_option_sack1 {
        tmp_5 = b.lookahead<bit<16>>();
        b.extract<Tcp_option_sack_h>(vec[32w1].sack, (bit<32>)((tmp_5[7:0] << 3) + 8w240));
        transition start2;
    }
    state parse_tcp_option_ss {
        b.extract<Tcp_option_ss_h>(vec[32w0].ss);
        transition start1;
    }
    state parse_tcp_option_ss1 {
        b.extract<Tcp_option_ss_h>(vec[32w1].ss);
        transition start2;
    }
    state start {
        tmp_0 = b.lookahead<bit<8>>();
        transition select(tmp_0) {
            8w0x0: parse_tcp_option_end;
            8w0x1: parse_tcp_option_nop;
            8w0x2: parse_tcp_option_ss;
            8w0x3: parse_tcp_option_s;
            8w0x5: parse_tcp_option_sack;
            default: noMatch;
        }
    }
    state start1 {
        tmp_0 = b.lookahead<bit<8>>();
        transition select(tmp_0) {
            8w0x0: parse_tcp_option_end1;
            8w0x1: parse_tcp_option_nop1;
            8w0x2: parse_tcp_option_ss1;
            8w0x3: parse_tcp_option_s1;
            8w0x5: parse_tcp_option_sack1;
            default: noMatch;
        }
    }
    state start2 {
        transition stateOutOfBound;
    }
}

parser pr<H>(packet_in b, out H h);
package top<H>(pr<H> p);
top<Tcp_option_h[10]>(Tcp_option_parser()) main;

