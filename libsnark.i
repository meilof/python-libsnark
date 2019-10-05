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

#include <iostream>
#include <fstream>

//void prove(const libsnark::r1cs_constraint_system<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>& cs, const char* ekfile, const char* vkfile) {
    
template<mp_size_t n, const bigint<n>& modulus>
void prettywrite(std::ostream &strm, const Fp_model<n, modulus> &val) {
    mpz_t t;
    mpz_init(t);
    val.as_bigint().to_mpz(t);
    strm << t;
    mpz_clear(t);       
}
    
template<mp_size_t n, const bigint<n>& modulus>
void prettywrite(std::ostream &strm, const Fp2_model<n, modulus> &el)
{
    prettywrite(strm, el.c0);
    strm << " ";
    prettywrite(strm, el.c1);
}
    
// formatting by https://github.com/christianlundkvist/libsnark-tutorial/blob/master/src/util.hpp

void prettywrite(ostream& strm, const libff::G1<default_r1cs_ppzksnark_pp>& pt) {
    libff::G1<default_r1cs_ppzksnark_pp> pp(pt);
    pp.to_affine_coordinates();
    prettywrite(strm, pp.X); strm << endl;
    prettywrite(strm, pp.Y); strm << endl;
}
    
void prettywrite(ostream& strm, const libff::G2<default_r1cs_ppzksnark_pp>& pt) {
    libff::G2<default_r1cs_ppzksnark_pp> pp(pt);
    pp.to_affine_coordinates();
    prettywrite(strm, pp.X); strm << endl;
    prettywrite(strm, pp.Y); strm << endl;
}


namespace libsnark {

class zks_protoboard_pub: public protoboard<FieldT> {
    vector<var_index_t> pubixs;
public:

    void setpublic(const pb_variable<FieldT> &var) {
        if (pubixs.size()>0 && pubixs.back()>=var.index) {
            cerr << "*** setpublic: pb_variables should be marked public in order, ignoring" << endl;
        } else {
            pubixs.push_back(var.index);
        }
    }
    
    r1cs_constraint_system<FieldT> get_constraint_system_pubs() {
        r1cs_constraint_system<FieldT> pbcs = get_constraint_system();
        r1cs_constraint_system<FieldT> cs;
        
        // build translation table
        int ntot = num_variables();
        vector<int> table(ntot+1);
        int cur = 1, curpub = 1, curshift = pubixs.size();
        table[0] = 0;
        for (auto const& ix: pubixs) {
            while (cur<ix) {
                table[cur] = cur+curshift;
                cur++;
            }
            table[cur++] = curpub++;
            curshift--;
        }
        while (cur <= ntot) {
            table[cur] = cur;
            cur++;
        }
        
        // reorganize constraint system
        for (auto csi: pbcs.constraints) {
            for (auto &ai: csi.a.terms) ai.index = table[ai.index];
            for (auto &bi: csi.b.terms) bi.index = table[bi.index];
            for (auto &ci: csi.c.terms) ci.index = table[ci.index];
            cs.add_constraint(csi);
        }
    
        cs.primary_input_size = pubixs.size();
        cs.auxiliary_input_size = num_variables() - pubixs.size();

        return cs;
    }
    
    r1cs_primary_input<FieldT> primary_input_pubs() {
        r1cs_primary_input<FieldT> ret;
        for (auto const& ix: pubixs) {
            ret.push_back(full_variable_assignment()[ix-1]);
        }
        return ret;
    }
    
    r1cs_auxiliary_input<FieldT> auxiliary_input_pubs() {
        r1cs_auxiliary_input<FieldT> ret;
        
        int ix = 1;
        vector<var_index_t>::iterator it = pubixs.begin();
        for (auto const& val: full_variable_assignment()) {
            if (it != pubixs.end() && *it==ix) {
                it++;
            } else {
                ret.push_back(val);
            }
            ix++;
        }
        return ret;
    }
    
};

};


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

%typemap(in, precedence=3000) libff::Fr<libsnark::default_r1cs_ppzksnark_pp> const& {
    long val;
    int overflow;
    val = PyLong_AsLongAndOverflow($input, &overflow);
    
    if (val!=-1 || (overflow==0 && !PyErr_Occurred())) {
        $1 = new FieldT(val);
    } else {
        PyObject *str = PyObject_Str($input);
        if (!str) { SWIG_fail; }
    
        const char* cstr = PyUnicode_AsUTF8(str);
        if (!cstr) { Py_DECREF(str); SWIG_fail; }
        
        $1 = new FieldT(libff::bigint<FieldT::num_limbs>(cstr));    
        Py_DECREF(str);
    }
}

%typemap(out, precedence=3000) libff::Fr<libsnark::default_r1cs_ppzksnark_pp> {
    stringstream ss;
    
    mpz_t t;
    mpz_init(t);
    $1.as_bigint().to_mpz(t);
    ss << t;
    mpz_clear(t);
    
    $result = PyLong_FromString(ss.str().c_str(), NULL, 10);    
}

%typemap(out, precedence=3001) libff::bigint<FieldT::num_limbs> {
    stringstream ss;
    
    mpz_t t;
    mpz_init(t);
    $1.to_mpz(t);
    ss << t;
    mpz_clear(t);
    
    $result = PyLong_FromString(ss.str().c_str(), NULL, 10);    
}


// todo: do typecheck to map field elements, etc to linearcombinations (then: lc(field) also not necessary)???

%inline %{
 
libff::Fr<libsnark::default_r1cs_ppzksnark_pp> fieldinverse(const libff::Fr<libsnark::default_r1cs_ppzksnark_pp>& val) {
    return val.inverse();
}
    
%}
libff::Fr<libsnark::default_r1cs_ppzksnark_pp> fieldinverse(const libff::Fr<libsnark::default_r1cs_ppzksnark_pp>& val);

%inline %{
 
libff::bigint<FieldT::num_limbs> get_modulus() {
    return FieldT::mod;
}
    
%}
libff::Fr<libsnark::default_r1cs_ppzksnark_pp> fieldinverse(const libff::Fr<libsnark::default_r1cs_ppzksnark_pp>& val);


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
%template(zks_linear_combination) libsnark::linear_combination<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
%template(zks_r1cs_constraint) libsnark::r1cs_constraint<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
%template(zks_r1cs_constraint_system) libsnark::r1cs_constraint_system<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
%template(zks_pb_variable) libsnark::pb_variable<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
%template(zks_protoboard) libsnark::protoboard<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;

%template(zks_r1cs_primary_input) libsnark::r1cs_primary_input<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
%template(zks_r1cs_auxiliary_input) libsnark::r1cs_auxiliary_input<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>;
%template(zks_r1cs_ppzksnark_proof) libsnark::r1cs_ppzksnark_proof<libsnark::default_r1cs_ppzksnark_pp>;


class zks_protoboard_pub: public libsnark::protoboard<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> {
public:
    void setpublic(const libsnark::pb_variable<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> &var);
    libsnark::r1cs_constraint_system<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> get_constraint_system_pubs();
    libsnark::r1cs_primary_input<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> primary_input_pubs();
    libsnark::r1cs_auxiliary_input<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> auxiliary_input_pubs();
    
};


%template(zks_keypair) libsnark::r1cs_ppzksnark_keypair<libsnark::default_r1cs_ppzksnark_pp>;
%template(zks_generator) libsnark::r1cs_ppzksnark_generator<libsnark::default_r1cs_ppzksnark_pp>;
%template(zks_prover) libsnark::r1cs_ppzksnark_prover<libsnark::default_r1cs_ppzksnark_pp>;
%template(zks_verifier_weak_IC) libsnark::r1cs_ppzksnark_verifier_weak_IC<libsnark::default_r1cs_ppzksnark_pp>;
%template(zks_verifier_strong_IC) libsnark::r1cs_ppzksnark_verifier_strong_IC<libsnark::default_r1cs_ppzksnark_pp>;


%inline %{
    
#include <iostream>
#include <fstream>
    
bool cseq(
    const libsnark::r1cs_constraint_system<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>& cs1,
    const libsnark::r1cs_constraint_system<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>& cs2) {
    if (cs1.constraints.size() != cs2.constraints.size()) return false;
    if (cs1.primary_input_size != cs2.primary_input_size) return false;
    if (cs1.auxiliary_input_size != cs2.auxiliary_input_size) return false;
    
    auto it1 = cs1.constraints.begin();
    auto it2 = cs2.constraints.begin();
    
    // libsnark may swap a and b so this is a bit involved
    while (it1!=cs1.constraints.end()) {
        if (!(it1->c==it2->c)) return false;
        if (it1->a==it2->a) {
            if (!(it1->b==it2->b)) return false;
        } else {
            if (!(it1->a==it2->b && it1->b==it2->a)) return false;
        }
        it1++;
        it2++;
    }
    return true;
}
    
libsnark::r1cs_ppzksnark_keypair<libsnark::default_r1cs_ppzksnark_pp>* read_key(const char* ekfile, const libsnark::r1cs_constraint_system<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>* cs = NULL) {
// read_key_or_generate(const libsnark::r1cs_constraint_system<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>& cs, const char* ekfile, const char* vkfile) {
    // try reading from file
    
    ifstream ek_data(ekfile);
    if (!ek_data.is_open()) return NULL;

    int sz1;
    ek_data >> sz1;
    
    // initial check to eliminate obvious non-matches
    if (cs!=NULL && (sz1!=cs->constraints.size())) return NULL;
        
    libsnark::r1cs_ppzksnark_keypair<libsnark::default_r1cs_ppzksnark_pp>* keys = 
        new libsnark::r1cs_ppzksnark_keypair<libsnark::default_r1cs_ppzksnark_pp>();
    
    ek_data >> keys->pk;
    ek_data >> keys->vk;
    ek_data.close();
    
    if (cs!=NULL && !cseq(keys->pk.constraint_system, *cs)) {
        delete keys;
        return NULL;
    }
    
    return keys;
}
    
template<typename T>
void prettywrite(std::ostream& out, const sparse_vector<T> &v)
{
    for (int i = 0; i < v.indices.size(); i++) {
        //out << v.indices[i] << endl;
        prettywrite(out, v.values[i]);
        //out << endl;
    }
//    out << v.domain_size_ << "\n";
//    out << v.indices.size() << "\n";
//    for (const size_t& i : v.indices)
//    {
//        out << i << "\n";
//    }
//
//    out << v.values.size() << "\n";
//    for (const T& t : v.values)
//    {
//        out << t << OUTPUT_NEWLINE;
//    }
}
    
template<typename T>
void prettywrite(std::ostream& out, const accumulation_vector<T> &v)
{
    out << (v.rest.indices.size()+1) << endl;
    prettywrite(out, v.first);
    prettywrite(out, v.rest);
}
    
template<typename ppT>
void prettywrite(std::ostream &out, const r1cs_ppzksnark_verification_key<ppT> &vk) {
    prettywrite(out, vk.alphaA_g2);
    prettywrite(out, vk.alphaB_g1);
    prettywrite(out, vk.alphaC_g2);
    prettywrite(out, vk.gamma_g2);
    prettywrite(out, vk.gamma_beta_g1);
    prettywrite(out, vk.gamma_beta_g2);
    prettywrite(out, vk.rC_Z_g2);
    prettywrite(out, vk.encoded_IC_query);    
}
    
void write_keys(const libsnark::r1cs_ppzksnark_keypair<default_r1cs_ppzksnark_pp>& keypair,
            const char* vkfile = NULL, const char* ekfile = NULL) {
    if (vkfile && *vkfile) {
        ofstream vk_data(vkfile);
        prettywrite(vk_data, keypair.vk);
        //vk_data << keypair.vk;
        vk_data.close();
    }
    
    if (ekfile && *ekfile) {
        ofstream ek_data(ekfile);
        ek_data << keypair.pk.constraint_system.constraints.size() << endl;
        ek_data << keypair.pk;
        ek_data << keypair.vk;
        ek_data.close();    
    }
}
    
%}

libsnark::r1cs_ppzksnark_keypair<libsnark::default_r1cs_ppzksnark_pp>* read_key
    (const char* ekfile,
     const libsnark::r1cs_constraint_system<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>* cs = NULL);
    
void write_keys(const libsnark::r1cs_ppzksnark_keypair<libsnark::default_r1cs_ppzksnark_pp>& keypair,
            const char* vkfile = NULL, const char* ekfile = NULL);

//libsnark::r1cs_ppzksnark_keypair<libsnark::default_r1cs_ppzksnark_pp> read_key_or_generate(const libsnark::r1cs_constraint_system<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>>& cs, const char* ekfile, const char* vkfile);



%inline %{
        
void write_proof(
    const libsnark::r1cs_ppzksnark_proof<libsnark::default_r1cs_ppzksnark_pp>& proof,
    const libsnark::r1cs_primary_input<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> pubvals,
    const char* logfile
) {
    ofstream prooffile(logfile);

    prooffile << pubvals.size() << endl;
    for (auto &it: pubvals) { prettywrite(prooffile, it); prooffile << endl; }

    prettywrite(prooffile, proof.g_A.g);
    prettywrite(prooffile, proof.g_A.h);
    prettywrite(prooffile, proof.g_B.g);
    prettywrite(prooffile, proof.g_B.h);
    prettywrite(prooffile, proof.g_C.g);
    prettywrite(prooffile, proof.g_C.h);
    prettywrite(prooffile, proof.g_H);
    prettywrite(prooffile, proof.g_K);

    prooffile.close();
}
%}

void write_proof(
    const r1cs_ppzksnark_proof<libsnark::default_r1cs_ppzksnark_pp>& proof,
    const libsnark::r1cs_primary_input<libff::Fr<libsnark::default_r1cs_ppzksnark_pp>> pubvals,
    const char* logfile
);


%init %{
	default_r1cs_ppzksnark_pp::init_public_params();
	libff::inhibit_profiling_info = true;
%}
