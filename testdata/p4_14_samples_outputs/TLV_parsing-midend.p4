header ipv4_option_timestamp_t_1 {
    bit<8> value;
    bit<8> len;
}

#include <core.p4>
#define V1MODEL_VERSION 20200408
#include <v1model.p4>

struct intrinsic_metadata_t {
    bit<4> mcast_grp;
    bit<4> egress_rid;
}

struct my_metadata_t {
    bit<8> parse_ipv4_counter;
}

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header ipv4_base_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header ipv4_option_security_t {
    bit<8>  value;
    bit<8>  len;
    bit<72> security;
}

header ipv4_option_timestamp_t {
    bit<8>      value;
    bit<8>      len;
    varbit<304> data;
}

header ipv4_option_EOL_t {
    bit<8> value;
}

header ipv4_option_NOP_t {
    bit<8> value;
}

struct metadata {
    bit<8> _my_metadata_parse_ipv4_counter0;
}

struct headers {
    @name(".ethernet") 
    ethernet_t              ethernet;
    @name(".ipv4_base") 
    ipv4_base_t             ipv4_base;
    @name(".ipv4_option_security") 
    ipv4_option_security_t  ipv4_option_security;
    @name(".ipv4_option_timestamp") 
    ipv4_option_timestamp_t ipv4_option_timestamp;
    @name(".ipv4_option_EOL") 
    ipv4_option_EOL_t[3]    ipv4_option_EOL;
    @name(".ipv4_option_NOP") 
    ipv4_option_NOP_t[3]    ipv4_option_NOP;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("ParserImpl.tmp_hdr") ipv4_option_timestamp_t_1 tmp_hdr_0;
    @name("ParserImpl.tmp_1") bit<8> tmp_1;
    bit<16> tmp_2;
    state stateOutOfBound {
        verify(false, error.StackOutOfBounds);
        transition reject;
    }
    state noMatch {
        verify(false, error.NoMatch);
        transition reject;
    }
    @name(".parse_ethernet") state parse_ethernet {
        packet.extract<ethernet_t>(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
    @name(".parse_ipv4") state parse_ipv4 {
        packet.extract<ipv4_base_t>(hdr.ipv4_base);
        meta._my_metadata_parse_ipv4_counter0 = (bit<8>)((hdr.ipv4_base.ihl << 2) + 4w12);
        transition select(hdr.ipv4_base.ihl) {
            4w0x5: accept;
            default: parse_ipv4_options;
        }
    }
    @name(".parse_ipv4_option_EOL") state parse_ipv4_option_EOL {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[32w0]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options16;
    }
    state parse_ipv4_option_EOL1 {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[32w0]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options15;
    }
    state parse_ipv4_option_EOL2 {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[32w0]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options12;
    }
    state parse_ipv4_option_EOL3 {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[32w0]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options9;
    }
    state parse_ipv4_option_EOL4 {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[32w1]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options10;
    }
    state parse_ipv4_option_EOL5 {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[32w2]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options11;
    }
    state parse_ipv4_option_EOL6 {
        transition stateOutOfBound;
    }
    state parse_ipv4_option_EOL7 {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[32w1]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options13;
    }
    state parse_ipv4_option_EOL8 {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[32w2]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options14;
    }
    state parse_ipv4_option_EOL9 {
        transition stateOutOfBound;
    }
    state parse_ipv4_option_EOL10 {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[32w1]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options16;
    }
    state parse_ipv4_option_EOL11 {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[32w2]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options17;
    }
    state parse_ipv4_option_EOL12 {
        transition stateOutOfBound;
    }
    @name(".parse_ipv4_option_NOP") state parse_ipv4_option_NOP {
        packet.extract<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[32w0]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options6;
    }
    state parse_ipv4_option_NOP1 {
        packet.extract<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[32w1]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options7;
    }
    state parse_ipv4_option_NOP2 {
        packet.extract<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[32w2]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options8;
    }
    state parse_ipv4_option_NOP3 {
        transition stateOutOfBound;
    }
    state parse_ipv4_option_NOP4 {
        transition stateOutOfBound;
    }
    state parse_ipv4_option_NOP5 {
        transition stateOutOfBound;
    }
    state parse_ipv4_option_NOP6 {
        transition stateOutOfBound;
    }
    state parse_ipv4_option_NOP7 {
        packet.extract<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[32w2]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options9;
    }
    state parse_ipv4_option_NOP8 {
        packet.extract<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[32w2]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options10;
    }
    state parse_ipv4_option_NOP9 {
        packet.extract<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[32w2]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options11;
    }
    state parse_ipv4_option_NOP10 {
        packet.extract<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[32w1]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options12;
    }
    state parse_ipv4_option_NOP11 {
        packet.extract<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[32w1]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options13;
    }
    state parse_ipv4_option_NOP12 {
        packet.extract<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[32w1]);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w255;
        transition parse_ipv4_options14;
    }
    @name(".parse_ipv4_option_security") state parse_ipv4_option_security {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options3;
    }
    state parse_ipv4_option_security1 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options5;
    }
    state parse_ipv4_option_security2 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options6;
    }
    state parse_ipv4_option_security3 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options7;
    }
    state parse_ipv4_option_security4 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options8;
    }
    state parse_ipv4_option_security5 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options9;
    }
    state parse_ipv4_option_security6 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options10;
    }
    state parse_ipv4_option_security7 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options11;
    }
    state parse_ipv4_option_security8 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options12;
    }
    state parse_ipv4_option_security9 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options13;
    }
    state parse_ipv4_option_security10 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options14;
    }
    state parse_ipv4_option_security11 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options15;
    }
    state parse_ipv4_option_security12 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options16;
    }
    state parse_ipv4_option_security13 {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 + 8w245;
        transition parse_ipv4_options17;
    }
    @name(".parse_ipv4_option_timestamp") state parse_ipv4_option_timestamp {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options1;
    }
    state parse_ipv4_option_timestamp1 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options2;
    }
    state parse_ipv4_option_timestamp2 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options4;
    }
    state parse_ipv4_option_timestamp3 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options6;
    }
    state parse_ipv4_option_timestamp4 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options7;
    }
    state parse_ipv4_option_timestamp5 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options8;
    }
    state parse_ipv4_option_timestamp6 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options9;
    }
    state parse_ipv4_option_timestamp7 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options10;
    }
    state parse_ipv4_option_timestamp8 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options11;
    }
    state parse_ipv4_option_timestamp9 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options12;
    }
    state parse_ipv4_option_timestamp10 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options13;
    }
    state parse_ipv4_option_timestamp11 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options14;
    }
    state parse_ipv4_option_timestamp12 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options15;
    }
    state parse_ipv4_option_timestamp13 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options16;
    }
    state parse_ipv4_option_timestamp14 {
        tmp_2 = packet.lookahead<bit<16>>();
        tmp_hdr_0.setValid();
        tmp_hdr_0.value = tmp_2[15:8];
        tmp_hdr_0.len = tmp_2[7:0];
        packet.extract<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp, ((bit<32>)tmp_2[7:0] << 3) + 32w4294967280);
        meta._my_metadata_parse_ipv4_counter0 = meta._my_metadata_parse_ipv4_counter0 - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options17;
    }
    @name(".parse_ipv4_options") state parse_ipv4_options {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp;
            default: noMatch;
        }
    }
    state parse_ipv4_options1 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp1;
            default: noMatch;
        }
    }
    state parse_ipv4_options2 {
        transition stateOutOfBound;
    }
    state parse_ipv4_options3 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security1;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp2;
            default: noMatch;
        }
    }
    state parse_ipv4_options4 {
        transition stateOutOfBound;
    }
    state parse_ipv4_options5 {
        transition stateOutOfBound;
    }
    state parse_ipv4_options6 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL1;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP1;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security2;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp3;
            default: noMatch;
        }
    }
    state parse_ipv4_options7 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL2;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP2;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security3;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp4;
            default: noMatch;
        }
    }
    state parse_ipv4_options8 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL3;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP3;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security4;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp5;
            default: noMatch;
        }
    }
    state parse_ipv4_options9 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL4;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP4;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security5;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp6;
            default: noMatch;
        }
    }
    state parse_ipv4_options10 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL5;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP5;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security6;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp7;
            default: noMatch;
        }
    }
    state parse_ipv4_options11 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL6;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP6;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security7;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp8;
            default: noMatch;
        }
    }
    state parse_ipv4_options12 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL7;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP7;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security8;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp9;
            default: noMatch;
        }
    }
    state parse_ipv4_options13 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL8;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP8;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security9;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp10;
            default: noMatch;
        }
    }
    state parse_ipv4_options14 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL9;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP9;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security10;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp11;
            default: noMatch;
        }
    }
    state parse_ipv4_options15 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL10;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP10;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security11;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp12;
            default: noMatch;
        }
    }
    state parse_ipv4_options16 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL11;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP11;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security12;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp13;
            default: noMatch;
        }
    }
    state parse_ipv4_options17 {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta._my_metadata_parse_ipv4_counter0, tmp_1) {
            (8w0x0, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0): parse_ipv4_option_EOL12;
            (8w0x0 &&& 8w0x0, 8w0x1): parse_ipv4_option_NOP12;
            (8w0x0 &&& 8w0x0, 8w0x82): parse_ipv4_option_security13;
            (8w0x0 &&& 8w0x0, 8w0x44): parse_ipv4_option_timestamp14;
            default: noMatch;
        }
    }
    @header_ordering("ethernet", "ipv4_base", "ipv4_option_security", "ipv4_option_NOP", "ipv4_option_timestamp", "ipv4_option_EOL") @name(".start") state start {
        tmp_hdr_0.setInvalid();
        transition parse_ethernet;
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @noWarn("unused") @name(".NoAction") action NoAction_1() {
    }
    @name(".format_options_security") action format_options_security() {
        hdr.ipv4_option_NOP.pop_front(3);
        hdr.ipv4_option_EOL.pop_front(3);
        hdr.ipv4_option_EOL.push_front(1);
        hdr.ipv4_option_EOL[0].setValid();
        hdr.ipv4_base.ihl = 4w8;
    }
    @name(".format_options_timestamp") action format_options_timestamp() {
        hdr.ipv4_option_NOP.pop_front(3);
        hdr.ipv4_option_EOL.pop_front(3);
        hdr.ipv4_base.ihl = (bit<4>)(8w5 + (hdr.ipv4_option_timestamp.len >> 3));
    }
    @name(".format_options_both") action format_options_both() {
        hdr.ipv4_option_NOP.pop_front(3);
        hdr.ipv4_option_EOL.pop_front(3);
        hdr.ipv4_option_NOP.push_front(1);
        hdr.ipv4_option_NOP[0].setValid();
        hdr.ipv4_option_NOP[0].value = 8w0x1;
        hdr.ipv4_base.ihl = (bit<4>)(8w8 + (hdr.ipv4_option_timestamp.len >> 2));
    }
    @name("._nop") action _nop() {
    }
    @name(".format_options") table format_options_0 {
        actions = {
            format_options_security();
            format_options_timestamp();
            format_options_both();
            _nop();
            @defaultonly NoAction_1();
        }
        key = {
            hdr.ipv4_option_security.isValid() : exact @name("ipv4_option_security.$valid$") ;
            hdr.ipv4_option_timestamp.isValid(): exact @name("ipv4_option_timestamp.$valid$") ;
        }
        size = 4;
        default_action = NoAction_1();
    }
    apply {
        format_options_0.apply();
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<ethernet_t>(hdr.ethernet);
        packet.emit<ipv4_base_t>(hdr.ipv4_base);
        packet.emit<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[0]);
        packet.emit<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[1]);
        packet.emit<ipv4_option_EOL_t>(hdr.ipv4_option_EOL[2]);
        packet.emit<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[0]);
        packet.emit<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[1]);
        packet.emit<ipv4_option_NOP_t>(hdr.ipv4_option_NOP[2]);
        packet.emit<ipv4_option_security_t>(hdr.ipv4_option_security);
        packet.emit<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp);
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

struct tuple_0 {
    bit<4>                  f0;
    bit<4>                  f1;
    bit<8>                  f2;
    bit<16>                 f3;
    bit<16>                 f4;
    bit<3>                  f5;
    bit<13>                 f6;
    bit<8>                  f7;
    bit<8>                  f8;
    bit<32>                 f9;
    bit<32>                 f10;
    ipv4_option_security_t  f11;
    ipv4_option_NOP_t       f12;
    ipv4_option_timestamp_t f13;
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
        update_checksum<tuple_0, bit<16>>(true, (tuple_0){f0 = hdr.ipv4_base.version,f1 = hdr.ipv4_base.ihl,f2 = hdr.ipv4_base.diffserv,f3 = hdr.ipv4_base.totalLen,f4 = hdr.ipv4_base.identification,f5 = hdr.ipv4_base.flags,f6 = hdr.ipv4_base.fragOffset,f7 = hdr.ipv4_base.ttl,f8 = hdr.ipv4_base.protocol,f9 = hdr.ipv4_base.srcAddr,f10 = hdr.ipv4_base.dstAddr,f11 = hdr.ipv4_option_security,f12 = hdr.ipv4_option_NOP[0],f13 = hdr.ipv4_option_timestamp}, hdr.ipv4_base.hdrChecksum, HashAlgorithm.csum16);
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;

