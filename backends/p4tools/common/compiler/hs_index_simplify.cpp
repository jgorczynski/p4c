#include "backends/p4tools/common/compiler/hs_index_simplify.h"

#include <string>

#include "lib/cstring.h"

namespace P4Tools {

const IR::Node* HSIndexToMember::postorder(IR::ArrayIndex* curArrayIndex) {
    if (const auto* arrayConst = curArrayIndex->right->to<IR::Constant>()) {
        return produceStackIndex(curArrayIndex->type, curArrayIndex->left, arrayConst->asInt());
    }
    return curArrayIndex;
}

const IR::Member* HSIndexToMember::produceStackIndex(const IR::Type* type,
                                                     const IR::Expression* expression,
                                                     int arrayIndex) {
    return new IR::Member(type, expression, cstring(std::to_string(arrayIndex)));
}

}  // namespace P4Tools
