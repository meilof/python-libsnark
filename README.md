Python3 bindings for libsnark.

Assumes [this libsnark branch](https://github.com/meilof/libsnark) is built with `cmake -DCURVE=ALT_BN128 -DUSE_PT_COMPRESSION=OFF -DWITH_PROCPS=OFF` and installed. If libsnark is built with different flags, `setup.py`'s `extra_compile_flags` should be adapted.

Install with:

```
python setup.py install
```

The wrapper is created using SWIG. To update the wrapper, use `swig -python -c++ -o alt_bn128_wrap.cpp libsnark.i`.

Under Linux, the following sequence of commands can be used to install libsnark:

```
git clone --recursive https://github.com/meilof/libsnark
cd libsnark/
mkdir build
cd build/
cmake .. -DCURVE=ALT_BN128 -DUSE_PT_COMPRESSION=OFF -DWITH_PROCPS=OFF
make
sudo make install
```

For Mac OS, flags like `-DCMAKE_PREFIX_PATH=/usr/local/Cellar/openssl/1.0.2t -DCMAKE_SHARED_LINKER_FLAGS=-L/usr/local/Cellar/openssl/1.0.2t/lib` can be added.
