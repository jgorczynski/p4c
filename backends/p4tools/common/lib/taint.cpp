#include "backends/p4tools/common/lib/taint.h"

#include <algorithm>
#include <utility>
#include <vector>

#include "backends/p4tools/common/lib/ir.h"
#include "backends/p4tools/common/lib/symbolic_env.h"
#include "lib/cstring.h"
#include "lib/exceptions.h"
#include "lib/null.h"

namespace P4Tools {

const IR::StringLiteral Taint::TAINTED_STRING_LITERAL = IR::StringLiteral(cstring("Taint"));

/// Returns a bitmask that indicates which bits of given expression are tainted given a complex
/// expression.
static bitvec computeTaintedBits(const SymbolicMapType& varMap, const IR::Expression* expr) {
    CHECK_NULL(expr);
    if (const auto* member = expr->to<IR::Member>()) {
        if (SymbolicEnv::isSymbolicValue(member)) {
            return {};
        }
        expr = varMap.at(member);
    }

    if (const auto* taintExpr = expr->to<IR::TaintExpression>()) {
        return {0, static_cast<size_t>(taintExpr->type->width_bits())};
    }

    if (const auto* concatExpr = expr->to<IR::Concat>()) {
        auto lTaint = computeTaintedBits(varMap, concatExpr->left);
        auto rTaint = computeTaintedBits(varMap, concatExpr->right);
        return (lTaint << concatExpr->right->type->width_bits()) | rTaint;
    }
    if (const auto* slice = expr->to<IR::Slice>()) {
        auto slLeftInt = slice->e1->checkedTo<IR::Constant>()->asInt();
        auto slRightInt = slice->e2->checkedTo<IR::Constant>()->asInt();
        auto subTaint = computeTaintedBits(varMap, slice->e0);
        return (subTaint >> slRightInt) & bitvec(0, slLeftInt - slRightInt + 1);
    }
    if (const auto* binaryExpr = expr->to<IR::Operation_Binary>()) {
        bitvec fullmask(0, expr->type->width_bits());
        if (const auto* shl = binaryExpr->to<IR::Shl>()) {
            if (const auto* shiftConst = shl->right->to<IR::Constant>()) {
                int shift = static_cast<int>(shiftConst->value);
                return fullmask & (computeTaintedBits(varMap, shl->left) << shift);
            }
            return fullmask;
        }
        if (const auto* shr = binaryExpr->to<IR::Shr>()) {
            if (const auto* shiftConst = shr->right->to<IR::Constant>()) {
                int shift = static_cast<int>(shiftConst->value);
                return computeTaintedBits(varMap, shr->left) >> shift;
            }
            return fullmask;
        }
        if (binaryExpr->is<IR::BAnd>() || binaryExpr->is<IR::BOr>() || binaryExpr->is<IR::BXor>()) {
            // Bitwise binary operations cannot taint other bits than those tainted in either lhs or
            // rhs.
            return computeTaintedBits(varMap, binaryExpr->left) |
                   computeTaintedBits(varMap, binaryExpr->right);
        }
        return fullmask;
    }
    if (const auto* unaryExpr = expr->to<IR::Operation_Unary>()) {
        return computeTaintedBits(varMap, unaryExpr->expr);
    }
    if (expr->is<IR::Literal>()) {
        return {};
    }
    if (expr->is<IR::DefaultExpression>()) {
        return {};
    }
    if (expr->is<IR::ConcolicVariable>()) {
        return {};
    }
    BUG("Taint pair collection is unsupported for %1% of type %2%", expr, expr->node_type_name());
}

bool Taint::hasTaint(const SymbolicMapType& varMap, const IR::Expression* expr) {
    if (expr->is<IR::TaintExpression>()) {
        return true;
    }
    if (const auto* member = expr->to<IR::Member>()) {
        if (!SymbolicEnv::isSymbolicValue(member)) {
            return hasTaint(varMap, varMap.at(member));
        }
        return false;
    }
    if (const auto* structExpr = expr->to<IR::StructExpression>()) {
        for (const auto* subExpr : structExpr->components) {
            if (hasTaint(varMap, subExpr->expression)) {
                return true;
            }
        }
        return false;
    }
    if (const auto* listExpr = expr->to<IR::ListExpression>()) {
        for (const auto* subExpr : listExpr->components) {
            if (hasTaint(varMap, subExpr)) {
                return true;
            }
        }
        return false;
    }
    if (const auto* binaryExpr = expr->to<IR::Operation_Binary>()) {
        return hasTaint(varMap, binaryExpr->left) || hasTaint(varMap, binaryExpr->right);
    }
    if (const auto* unaryExpr = expr->to<IR::Operation_Unary>()) {
        return hasTaint(varMap, unaryExpr->expr);
    }
    if (expr->is<IR::Literal>()) {
        return false;
    }
    if (const auto* slice = expr->to<IR::Slice>()) {
        auto slLeftInt = slice->e1->checkedTo<IR::Constant>()->asInt();
        auto slRightInt = slice->e2->checkedTo<IR::Constant>()->asInt();
        auto taint = computeTaintedBits(varMap, slice->e0);
        return !(taint & bitvec(slRightInt, slLeftInt - slRightInt + 1)).empty();
    }
    if (expr->is<IR::DefaultExpression>()) {
        return false;
    }
    if (expr->is<IR::ConcolicVariable>()) {
        return false;
    }
    BUG("Taint checking is unsupported for %1% of type %2%", expr, expr->node_type_name());
}

class TaintPropagator : public Transform {
    const SymbolicMapType& varMap;

    const IR::Node* postorder(IR::Expression* node) override {
        P4C_UNIMPLEMENTED("Taint transformation not supported for node %1% of type %2%", node,
                          node->node_type_name());
    }

    const IR::Node* postorder(IR::Type* type) override {
        // Types can not have taint, just return them.
        return type;
    }

    const IR::Node* postorder(IR::Literal* lit) override {
        // Literals can also not have taint, just return them.
        return lit;
    }

    const IR::Node* postorder(IR::PathExpression* path) override {
        // Path expressions as part of members can be encountered during the post-order traversal.
        // Ignore them.
        return path;
    }

    const IR::Node* postorder(IR::TaintExpression* expr) override { return expr; }

    const IR::Node* postorder(IR::ConcolicVariable* var) override {
        return new IR::Constant(var->type, IRUtils::getMaxBvVal(var->type));
    }
    const IR::Node* postorder(IR::Operation_Unary* unary_op) override { return unary_op->expr; }

    const IR::Node* postorder(IR::Member* member) override {
        // We do not want to split members.
        return member;
    }

    const IR::Node* postorder(IR::Cast* cast) override {
        if (Taint::hasTaint(varMap, cast->expr)) {
            // Try to cast the taint to whatever type is specified.
            auto* taintClone = cast->expr->clone();
            taintClone->type = cast->destType;
            return taintClone;
        }
        // Otherwise we convert the expression to a constant of the cast type.
        // Ultimately, the value here does not matter.
        return IRUtils::getDefaultValue(cast->destType);
    }

    const IR::Node* postorder(IR::Operation_Binary* bin_op) override {
        if (Taint::hasTaint(varMap, bin_op->right)) {
            return bin_op->right;
        }
        return bin_op->left;
    }

    const IR::Node* postorder(IR::Concat* concat) override { return concat; }

    const IR::Node* postorder(IR::Operation_Ternary* ternary_op) override {
        BUG("Operation ternary %1% of type %2% should not be encountered in the taint propagator.",
            ternary_op, ternary_op->node_type_name());
    }

    const IR::Node* preorder(IR::Slice* slice) override {
        // We assume a bit type here...
        BUG_CHECK(!slice->e0->is<IR::Type_Bits>(),
                  "Expected Type_Bits for the slice expression but received %1%",
                  slice->e0->type->node_type_name());
        auto slLeftInt = slice->e1->checkedTo<IR::Constant>()->asInt();
        auto slRightInt = slice->e2->checkedTo<IR::Constant>()->asInt();
        auto width = 1 + slLeftInt - slRightInt;
        const auto* sliceTb = IRUtils::getBitType(width);
        if (Taint::hasTaint(varMap, slice)) {
            return IRUtils::getTaintExpression(sliceTb);
        }
        // Otherwise we convert the expression to a constant of the sliced type.
        // Ultimately, the value here does not matter.
        return IRUtils::getConstant(sliceTb, 0);
    }

 public:
    explicit TaintPropagator(const SymbolicMapType& varMap) : varMap(varMap) {
        visitDagOnce = false;
    }
};

class MaskBuilder : public Transform {
 private:
    const IR::Node* preorder(IR::Member* member) override {
        // Non-tainted members just return the max value, which corresponds to a mask of all zeroes.
        return IRUtils::getConstant(member->type, IRUtils::getMaxBvVal(member->type));
    }

    const IR::Node* preorder(IR::TaintExpression* taintExpr) override {
        // If the member is tainted, we set the mask to ones corresponding to the width of the
        // value.
        return IRUtils::getDefaultValue(taintExpr->type);
    }

    const IR::Node* preorder(IR::Literal* lit) override {
        // Fill out a literal with zeroes.
        const auto* maxConst = IRUtils::getConstant(lit->type, IRUtils::getMaxBvVal(lit->type));
        // If the literal would have been zero anyway, just return it.
        if (lit->equiv(*maxConst)) {
            return lit;
        }
        return maxConst;
    }

 public:
    MaskBuilder() { visitDagOnce = false; }
};

const IR::Literal* Taint::buildTaintMask(const SymbolicMapType& varMap, const Model* completedModel,
                                         const IR::Expression* programPacket) {
    // First propagate taint and simplify the packet.
    const auto* taintedPacket = programPacket->apply(TaintPropagator(varMap));
    // Then create the mask based on the remaining expressions.
    const auto* mask = taintedPacket->apply(MaskBuilder());
    // Produce the evaluated literal. The hex expression should only have 0 or f.
    return completedModel->evaluate(mask);
}

const IR::Expression* Taint::propagateTaint(const SymbolicMapType& varMap,
                                            const IR::Expression* expr) {
    return expr->apply(TaintPropagator(varMap));
}

const IR::Expression* buildMask(const IR::Expression* expr) { return expr->apply(MaskBuilder()); }

}  // namespace P4Tools
