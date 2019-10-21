  
// taken from https://stackoverflow.com/questions/18860816/technique-for-using-stdifstream-stdofstream-in-python-via-swig

%fragment("iostream_header", "header") %{
#include <stdio.h>
#include <memory>
#include <boost/iostreams/stream.hpp>
#include <boost/iostreams/device/file_descriptor.hpp>
using boost_ofd_stream = boost::iostreams::stream<boost::iostreams::file_descriptor_sink>;
using boost_ifd_stream = boost::iostreams::stream<boost::iostreams::file_descriptor_source>;
%}  

%typemap(in, fragment="iostream_header") std::ostream& (std::unique_ptr<boost_ofd_stream> stream) {
    PyObject *flush_result = PyObject_CallMethod($input, const_cast<char*>("flush"), nullptr);
    if (flush_result) Py_DECREF(flush_result);
%#if PY_VERSION_HEX < 0x03000000
    int fd = fileno(PyFile_AsFile($input));
%#else
    int fd = PyObject_AsFileDescriptor($input);
%#endif
    if (fd < 0) { SWIG_Error(SWIG_TypeError, "File object expected."); SWIG_fail; }
    stream = std::make_unique<boost_ofd_stream>(fd, boost::iostreams::never_close_handle);
    $1 = stream.get();
}   

%typemap(in, fragment="iostream_header") std::istream& (std::unique_ptr<boost_ifd_stream> stream) {
%#if PY_VERSION_HEX < 0x03000000
    int fd = fileno(PyFile_AsFile($input));
%#else
    int fd = PyObject_AsFileDescriptor($input);
%#endif
    if (fd < 0) { SWIG_Error(SWIG_TypeError, "File object expected.");  SWIG_fail; }
    stream = std::make_unique<boost_ifd_stream>(fd, boost::iostreams::never_close_handle);
    $1 = stream.get();
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_INTEGER) std::istream& {
  $1 = (PyObject_AsFileDescriptor($input)>=0);
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_INTEGER) std::ostream& {
  $1 = (PyObject_AsFileDescriptor($input)>=0);
}


%include "std_string.i"
    
%define SYNTHESIS(TT)
    
%extend TT {
  void write(std::ostream& str = std::cout) {
      str << *$self;
  }
  static TT* read(std::istream& str = std::cin) {
      TT* ret = new TT();
      str >> *ret;
      return ret;
  }
  std::string str() {
    bool old_binary_output = libff::binary_output; libff::binary_output = false;
    bool old_montgomery_output = libff::montgomery_output; libff::montgomery_output = false;
    bool old_no_pt_compression = libff::no_pt_compression; libff::no_pt_compression = false;
    
    stringstream ss;
    ss << *$self;
      
    libff::binary_output = old_binary_output;
    libff::montgomery_output = old_montgomery_output;
    libff::no_pt_compression = old_no_pt_compression;      
      
    return ss.str();
  }
    
  static TT* fromstr(const std::string& str) {
    bool old_binary_output = libff::binary_output; libff::binary_output = false;
    bool old_montgomery_output = libff::montgomery_output; libff::montgomery_output = false;
    bool old_no_pt_compression = libff::no_pt_compression; libff::no_pt_compression = false;
    
    stringstream ss(str);
    TT* ret = new TT();
    ss >> *ret;
      
    libff::binary_output = old_binary_output;
    libff::montgomery_output = old_montgomery_output;
    libff::no_pt_compression = old_no_pt_compression;      
      
    return ret;      
  }
};
%enddef



SYNTHESIS(libff::G1<libff::alt_bn128_pp>)
SYNTHESIS(libff::G2<libff::alt_bn128_pp>)
//SYNTHESIS(libsnark::knowledge_commitment<libff::G1<libff::alt_bn128_pp>,libff::G1<libff::alt_bn128_pp>>)
//SYNTHESIS(libsnark::knowledge_commitment<libff::G2<libff::alt_bn128_pp>,libff::G1<libff::alt_bn128_pp>>)
//SYNTHESIS(libsnark::variable<Ft>)
//SYNTHESIS(libsnark::pb_variable<Ft>)
SYNTHESIS(libsnark::linear_combination<Ft>)
SYNTHESIS(libsnark::r1cs_constraint<Ft>)
SYNTHESIS(libsnark::r1cs_constraint_system<Ft>)
SYNTHESIS(libsnark::r1cs_primary_input<Ft>)
SYNTHESIS(libsnark::r1cs_auxiliary_input<Ft>)
//SYNTHESIS(libsnark::protoboard<Ft>)
SYNTHESIS(libsnark::r1cs_ppzksnark_proof<libff::alt_bn128_pp>)
//SYNTHESIS(libsnark::r1cs_ppzksnark_keypair<libff::alt_bn128_pp>)
SYNTHESIS(libsnark::r1cs_ppzksnark_verification_key<libff::alt_bn128_pp>)
SYNTHESIS(libsnark::r1cs_ppzksnark_proving_key<libff::alt_bn128_pp>)
    
