Python3 bindings for a minimal subset of libsnark. Currently supports Pinocchio and Groth proofs on the `alt_bn128` curve, compatible with snarkjs, websnark, Solidity pairings, etc.

See [minimal examlple](https://github.com/meilof/python-libsnark/blob/master/examples/test.py) and [use in PySNARK](https://github.com/meilof/pysnark/blob/master/pysnark/libsnark/backend.py).

Install from pip with

```
pip install python-libsnark
```

Binary versions available at [PyPi](https://pypi.org/manage/project/python-libsnark/release/0.3.1/) for Linux (Python 3.5, 3.6, 3.7, 3.8), Mac OS (Python 3.7), and Windows (Python 3.7 32-bit/64-bit).

## Functionality

The following classes of libsnark are currently wrapped:

General:

```
typedef libff::Fr<libff::alt_bn128_pp> Ft;
%template(Variable) libsnark::variable<Ft>;
%template(PbVariable) libsnark::pb_variable<Ft>;
%template(LinearCombination) libsnark::linear_combination<Ft>;
%template(R1csConstraint) libsnark::r1cs_constraint<Ft>;
%template(R1csConstraintSystem) libsnark::r1cs_constraint_system<Ft>;
%template(R1csPrimaryInput) libsnark::r1cs_primary_input<Ft>;
%template(R1csAuxiliaryInput) libsnark::r1cs_auxiliary_input<Ft>;
%template(Protoboard) libsnark::protoboard<Ft>;
```

Pinocchio zk-SNARK (aka 8-point proofs):

```
%template(ZKProof) libsnark::r1cs_ppzksnark_proof<libff::alt_bn128_pp>;
%template(ZKKeypair) libsnark::r1cs_ppzksnark_keypair<libff::alt_bn128_pp>;
%template(zk_generator) libsnark::r1cs_ppzksnark_generator<libff::alt_bn128_pp>;
%template(zk_prover) libsnark::r1cs_ppzksnark_prover<libff::alt_bn128_pp>;
%template(zk_verifier_weak_IC) libsnark::r1cs_ppzksnark_verifier_weak_IC<libff::alt_bn128_pp>;
%template(zk_verifier_strong_IC) libsnark::r1cs_ppzksnark_verifier_strong_IC<libff::alt_bn128_pp>;
```

Groth 3-point proof:

```
%template(ZKGGProof) libsnark::r1cs_gg_ppzksnark_proof<libff::alt_bn128_pp>;
%template(ZKGGKeypair) libsnark::r1cs_gg_ppzksnark_keypair<libff::alt_bn128_pp>;
%template(zkgg_generator) libsnark::r1cs_gg_ppzksnark_generator<libff::alt_bn128_pp>;
%template(zkgg_prover) libsnark::r1cs_gg_ppzksnark_prover<libff::alt_bn128_pp>;
%template(zkgg_verifier_weak_IC) libsnark::r1cs_gg_ppzksnark_verifier_weak_IC<libff::alt_bn128_pp>;
%template(zkgg_verifier_strong_IC) libsnark::r1cs_gg_ppzksnark_verifier_strong_IC<libff::alt_bn128_pp>;
```

## Known issues

* Evaluation keys are not compatible between 32-bit and 64-bit versions of the module because of the use of Montgomery representations. Verification keys should be OK. This may be fixed in future versions.

## Building from source

When building from source it is assumed tht [this libsnark branch](https://github.com/meilof/libsnark) is built with `cmake -DCURVE=ALT_BN128 -DUSE_PT_COMPRESSION=OFF -DWITH_PROCPS=OFF` and installed. If libsnark is built with different flags, `setup.py`'s `extra_compile_flags` should be adapted.

Under Linux, the following sequence of commands can be used to install libsnark:

```
git clone --recursive https://github.com/meilof/libsnark
cd libsnark/
mkdir build
cd build/
cmake .. -DCURVE=ALT_BN128 -DUSE_PT_COMPRESSION=OFF -DWITH_PROCPS=OFF -DBINARY_OUTPUT=OFF
make
sudo make install
```

For Mac OS, flags like `-DCMAKE_PREFIX_PATH=/usr/local/Cellar/openssl/1.0.2t -DCMAKE_SHARED_LINKER_FLAGS=-L/usr/local/Cellar/openssl/1.0.2t/lib` can be added.

The wrapper is created using SWIG. To update the wrapper, use `swig -python -c++ -o alt_bn128_wrap.cpp libsnark.i`.

### Mac OS X

To compile libsnark, use:

```
sudo cmake -DCMAKE_PREFIX_PATH=/usr/local/Cellar/openssl/1.0.2t -DCMAKE_SHARED_LINKER_FLAGS=-L/usr/local/Cellar/openssl/1.0.2t/lib -DWITH_PROCPS=OFF -DWITH_SUPERCOP=OFF -DOPT_FLAGS=-std=c++11 -DCURVE=ALT_BN128 ..
```

### To build manylinux packages

```
docker run -it -v $(pwd):/io quay.io/pypa/manylinux2010_x86_64
```
inside the docker:
```
yum install cmake3 openssl-devel boost-devel
build and install libgmp with ./configure --enable-cxx; make install
cmake3 .. -DCURVE=ALT_BN128 -DUSE_PT_COMPRESSION=OFF -DWITH_PROCPS=OFF -DBINARY_OUTPUT=OFF
make install
cd python-libsnark
/opt/python/cp34-cp34m/bin/pip wheel . -w wheelhouse/
auditwheel repair /io/python-libsnark/wheelhouse/python_libsnark-0.3.2-cp38-cp38-linux_x86_64.whl 
etc
twine upload *
```
