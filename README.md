Python3 bindings for libsnark.

Assumes libsnark is built with `-DBINARY_OUTPUT=ON -DMONTGOMERY_OUTPUT=ON -DUSE_PT_COMPRESSION=OFF` and installed.

Install with:

```
python setup.py install
```

The wrapper is created using SWIG. To update the wrapper, use `swig -python -c++ -o alt_bn128_wrap.cpp libsnark.i`.

