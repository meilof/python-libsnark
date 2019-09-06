%module libsnark
%{
 

#include "libff/algebra/fields/field_utils.hpp"
#include "libsnark/zk_proof_systems/ppzksnark/r1cs_ppzksnark/r1cs_ppzksnark.hpp"
#include "libsnark/common/default_types/r1cs_ppzksnark_pp.hpp"


#include "libsnark/relations/variable.hpp"
#include "libsnark/relations/constraint_satisfaction_problems/r1cs/r1cs.hpp"

#include "libsnark/gadgetlib1/protoboard.hpp"
#include "libsnark/gadgetlib1/gadgets/hashes/knapsack/knapsack_gadget.hpp"

using namespace libsnark;
using namespace std;
using namespace libff;

typedef libff::Fr<default_r1cs_ppzksnark_pp> FieldT;


//template<mp_size_t n>
//libff::bigint<n> libff::bigint<n>::one() {
//    return libff::bigint<n>(1);
//}


%}

//namespace libff {
//template<typename EC_ppT>
//using Fr = typename EC_ppT::Fp_type;
//    
//%include "fp_model.i"
//}

%typemap(typecheck) libff::Fr<libsnark::default_r1cs_ppzksnark_pp> const& {
  $1 = PyLong_Check($input) ? 1 : 0;
}

// leaks memory?
%typemap(in, precedence=3000) libff::Fr<libsnark::default_r1cs_ppzksnark_pp> const& {
    long val;
    int overflow;
    val = PyLong_AsLongAndOverflow($input, &overflow);
    
    if (val!=-1 || (overflow==0 && !PyErr_Occurred())) {
        cerr << "succeeded via int" << endl;
        $1 = new FieldT(val);
    } else {
        cerr << "trying via obj" << endl;
        PyObject *str = PyObject_Str($input);
        if (!str) { SWIG_fail; }
    
        const char* cstr = PyUnicode_AsUTF8(str);
        if (!cstr) { Py_DECREF(str); SWIG_fail; }
        
        $1 = new FieldT(libff::bigint<FieldT::num_limbs>(cstr));    
        Py_DECREF(str);
    }
}

// todo: do typecheck to map field elements, etc to linearcombinations (then: lc(field) also not necessary)???


 
namespace libsnark {

%include "variable.i"
%include "pb_variable.i"
%include "r1cs.i"
%include "protoboard.i"
%include "r1cs_ppzksnark.i"
    
}

%extend libsnark::protoboard<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> {
  void libsnark::protoboard<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>::setval(const pb_variable<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> &varn, libff::Fr<libsnark::default_r1cs_ppzksnark_pp> const& valu) {
      $self->val(varn) = valu;
  }
};

//%extend libsnark::protoboard<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> {
//  libsnark::linear_combination<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> new_variable() {
//      pb_variable<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> tmp = pb_variable<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>();
//      tmp.allocate(*$self);
//      return libsnark::linear_combination<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>(tmp);
//  }
//};


//%template(fp) libff::Fr<libsnark::default_r1cs_ppzksnark_pp>;

//%template(variable) libsnark::variable<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
//%template(linear_term) libsnark::linear_term<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
%template(linear_combination) libsnark::linear_combination<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
%template(r1cs_constraint) libsnark::r1cs_constraint<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
%template(r1cs_constraint_system) libsnark::r1cs_constraint_system<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
%template(pb_variable) libsnark::pb_variable<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
%template(protoboard) libsnark::protoboard<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;


%template(r1cs_ppzksnark_keypair) libsnark::r1cs_ppzksnark_keypair<libsnark::default_r1cs_ppzksnark_pp>;
%template(r1cs_ppzksnark_generator) libsnark::r1cs_ppzksnark_generator<libsnark::default_r1cs_ppzksnark_pp>;

%init %{
	default_r1cs_ppzksnark_pp::init_public_params();
	libff::inhibit_profiling_info = true;
%}

// ../libsnark/libsnark/relations/variable.tcc:106:37: error: no member named 'one' in 'libff::bigint<4>'
// ../libsnark/libsnark/relations/variable.tcc:500:30: error: no viable overloaded '+='
// ../libsnark/libsnark/relations/variable.tcc:131:57: error: invalid operands to binary expression ('const libff::bigint<4>' and
//      'const libff::bigint<4>') [*]
//%template(variable) libsnark::variable<libff::bigint<FieldT::num_limbs>>;
//%template(linear_combination) libsnark::linear_combination<libff::bigint<FieldT::num_limbs>>;
//%template(r1cs_constraint) libsnark::r1cs_constraint<libff::bigint<FieldT::num_limbs>>;
//%template(pb_variable) libsnark::pb_variable<libff::bigint<FieldT::num_limbs>>;
//%template(protoboard) libsnark::protoboard<libff::bigint<FieldT::num_limbs>>;