#include <core.p4>

header H {
    int<16> a;
}

struct metadata {
}

struct Headers {
    H h;
}

parser p(packet_in packet, out Headers hdr) {
    state start {
        packet.extract(hdr.h);
        transition select(hdr.h.a) {
            -5 .. 4: parse;
            default: accept;
        }
    }
    state parse {
        hdr.h.a = -1;
        transition accept;
    }
}

parser Parser(packet_in b, out Headers hdr);
package top(Parser p);
top(p()) main;

