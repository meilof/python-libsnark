%module alt_bn128

%feature("autodoc", "1");
    
%{

//#include "libsnark/common/default_types/r1cs_ppzksnark_pp.hpp"
//#include "libsnark/common/default_types/r1cs_gg_ppzksnark_pp.hpp"

#include <libff/algebra/curves/alt_bn128/alt_bn128_pp.hpp>

#include "libff/algebra/fields/field_utils.hpp"
#include "libsnark/gadgetlib1/protoboard.hpp"
#include "libsnark/gadgetlib1/gadgets/hashes/knapsack/knapsack_gadget.hpp"
#include "libsnark/relations/variable.hpp"
#include "libsnark/relations/constraint_satisfaction_problems/r1cs/r1cs.hpp"
#include "libsnark/zk_proof_systems/ppzksnark/r1cs_ppzksnark/r1cs_ppzksnark.hpp"
#include "libsnark/zk_proof_systems/ppzksnark/r1cs_gg_ppzksnark/r1cs_gg_ppzksnark.hpp"

using namespace libsnark;
using namespace std;
using namespace libff;

%}

%{
typedef libff::Fr<libff::alt_bn128_pp> Ft;
typedef libff::alt_bn128_Fq Fqt;
typedef libff::alt_bn128_Fq2 Fq2t;
%}

class Ft { };
class Fqt { };

%include "swigtypes.i"

class Fq2t {  };
%extend Fq2t {
Fqt Fq2t::getc0() { return $self->c0; }
Fqt Fq2t::getc1() { return $self->c1; }
};

%inline %{ 
Ft fieldinverse(const Ft& val) {
    return val.inverse();
}
 
libff::bigint<Ft::num_limbs> get_modulus() {
    return Ft::mod;
}    
%}

%include "alt_bn128_g1.i"
%include "alt_bn128_g2.i"
namespace libff {
%template(G1) libff::G1<libff::alt_bn128_pp>;
%template(G2) libff::G2<libff::alt_bn128_pp>;
}

%include "knowledge_commitment.i"
namespace libsnark {
%template(KnowledgeCommitmentG1G1) libsnark::knowledge_commitment<libff::G1<libff::alt_bn128_pp>,libff::G1<libff::alt_bn128_pp>>;
%template(KnowledgeCommitmentG2G1) libsnark::knowledge_commitment<libff::G2<libff::alt_bn128_pp>,libff::G1<libff::alt_bn128_pp>>;
}


namespace libsnark {
%include "variable.i"
}
%template(Variable) libsnark::variable<Ft>;

namespace libsnark {
%include "pb_variable.i"
}
%template(PbVariable) libsnark::pb_variable<Ft>;
%template(LinearCombination) libsnark::linear_combination<Ft>;

namespace libsnark {
%include "r1cs.i"
}
%template(R1csConstraint) libsnark::r1cs_constraint<Ft>;
%template(R1csConstraintSystem) libsnark::r1cs_constraint_system<Ft>;
%template(R1csPrimaryInput) libsnark::r1cs_primary_input<Ft>;
%template(R1csAuxiliaryInput) libsnark::r1cs_auxiliary_input<Ft>;

namespace libsnark {
%include "protoboard.i"
}
%extend libsnark::protoboard<Ft> {
  void libsnark::protoboard<Ft>::setval(const pb_variable<Ft> &varn, Ft const& valu) {
      $self->val(varn) = valu;
  }
};
%template(Protoboard) libsnark::protoboard<Ft>;

%include "protoboard_pub.i"

%include "io.i"
    
namespace libsnark {
%include "r1cs_ppzksnark.i"
}
%template(ZKProof) libsnark::r1cs_ppzksnark_proof<libff::alt_bn128_pp>;
%template(ZKKeypair) libsnark::r1cs_ppzksnark_keypair<libff::alt_bn128_pp>;
%template(ZKVerificationKey) libsnark::r1cs_ppzksnark_verification_key<libff::alt_bn128_pp>;
%template(zk_generator) libsnark::r1cs_ppzksnark_generator<libff::alt_bn128_pp>;
%template(zk_prover) libsnark::r1cs_ppzksnark_prover<libff::alt_bn128_pp>;
%template(zk_verifier_weak_IC) libsnark::r1cs_ppzksnark_verifier_weak_IC<libff::alt_bn128_pp>;
%template(zk_verifier_strong_IC) libsnark::r1cs_ppzksnark_verifier_strong_IC<libff::alt_bn128_pp>;
%include "io_zk.i"
    
namespace libsnark {
%include "r1cs_gg_ppzksnark.i"
}
%template(ZKGGProof) libsnark::r1cs_gg_ppzksnark_proof<libff::alt_bn128_pp>;
%template(ZKGGKeypair) libsnark::r1cs_gg_ppzksnark_keypair<libff::alt_bn128_pp>;
%template(zkgg_generator) libsnark::r1cs_gg_ppzksnark_generator<libff::alt_bn128_pp>;
%template(zkgg_prover) libsnark::r1cs_gg_ppzksnark_prover<libff::alt_bn128_pp>;
%template(zkgg_verifier_weak_IC) libsnark::r1cs_gg_ppzksnark_verifier_weak_IC<libff::alt_bn128_pp>;
%template(zkgg_verifier_strong_IC) libsnark::r1cs_gg_ppzksnark_verifier_strong_IC<libff::alt_bn128_pp>;
%include "io_zkgg.i"
    



%init %{
	libff::alt_bn128_pp::init_public_params();
	libff::inhibit_profiling_info = true;
%}
