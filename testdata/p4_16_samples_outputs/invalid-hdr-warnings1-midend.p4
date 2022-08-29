#include <core.p4>
#define V1MODEL_VERSION 20200408
#include <v1model.p4>

header Header {
    bit<32> data;
}

struct H {
    Header h1;
    Header h2;
}

struct M {
}

parser ParserI(packet_in pkt, out H hdr, inout M meta, inout standard_metadata_t smeta) {
    state stateOutOfBound {
        verify(false, error.StackOutOfBounds);
        transition reject;
    }
    state next {
        transition select((bit<1>)(hdr.h2.data == 32w1)) {
            1w1: next_true;
            1w0: next_join;
            default: noMatch;
        }
    }
    state next1 {
        transition select((bit<1>)(hdr.h2.data == 32w1)) {
            1w1: next_true;
            1w0: next_join1;
            default: noMatch;
        }
    }
    state next2 {
        transition select((bit<1>)(hdr.h2.data == 32w1)) {
            1w1: next_true;
            1w0: next_join2;
            default: noMatch;
        }
    }
    state next_join {
        pkt.extract<Header>(hdr.h1);
        hdr.h2.setInvalid();
        transition select(hdr.h1.data) {
            32w0: state0;
            32w1: state1;
            default: accept;
        }
    }
    state next_join1 {
        pkt.extract<Header>(hdr.h1);
        hdr.h2.setInvalid();
        transition select(hdr.h1.data) {
            32w0: state01;
            32w1: state13;
            default: accept;
        }
    }
    state next_join2 {
        pkt.extract<Header>(hdr.h1);
        hdr.h2.setInvalid();
        transition select(hdr.h1.data) {
            32w0: state02;
            32w1: state15;
            default: accept;
        }
    }
    state next_join3 {
        pkt.extract<Header>(hdr.h1);
        hdr.h2.setInvalid();
        transition select(hdr.h1.data) {
            32w0: state03;
            32w1: state16;
            default: accept;
        }
    }
    state next_true {
        transition next_join3;
    }
    state noMatch {
        verify(false, error.NoMatch);
        transition reject;
    }
    state start {
        hdr.h2.data = 32w1;
        transition next;
    }
    state state0 {
        hdr.h1.setInvalid();
        transition select(hdr.h2.data) {
            32w2: state12;
            default: next1;
        }
    }
    state state01 {
        hdr.h1.setInvalid();
        transition select(hdr.h2.data) {
            32w2: state14;
            default: next2;
        }
    }
    state state02 {
        transition stateOutOfBound;
    }
    state state03 {
        transition stateOutOfBound;
    }
    state state04 {
        transition stateOutOfBound;
    }
    state state1 {
        hdr.h2.data = hdr.h2.data + 32w1;
        hdr.h2.setValid();
        transition select(hdr.h2.data) {
            32w1: state11;
            32w2: state0;
            default: accept;
        }
    }
    state state11 {
        transition stateOutOfBound;
    }
    state state12 {
        transition stateOutOfBound;
    }
    state state13 {
        transition stateOutOfBound;
    }
    state state14 {
        hdr.h2.data = hdr.h2.data + 32w1;
        hdr.h2.setValid();
        transition select(hdr.h2.data) {
            32w1: state17;
            32w2: state04;
            default: accept;
        }
    }
    state state15 {
        transition stateOutOfBound;
    }
    state state16 {
        transition stateOutOfBound;
    }
    state state17 {
        transition stateOutOfBound;
    }
}

control IngressI(inout H hdr, inout M meta, inout standard_metadata_t smeta) {
    apply {
    }
}

control EgressI(inout H hdr, inout M meta, inout standard_metadata_t smeta) {
    apply {
    }
}

control DeparserI(packet_out pk, in H hdr) {
    apply {
    }
}

control VerifyChecksumI(inout H hdr, inout M meta) {
    apply {
    }
}

control ComputeChecksumI(inout H hdr, inout M meta) {
    apply {
    }
}

V1Switch<H, M>(ParserI(), VerifyChecksumI(), IngressI(), EgressI(), ComputeChecksumI(), DeparserI()) main;

