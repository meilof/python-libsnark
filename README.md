Python3 bindings for libsnark. Minimal example:

```
cd build
cmake ..
make 
cp ../examples/test.py .
python3 test.py
```

Magical line for Mac OS

```
cmake -DCMAKE_PREFIX_PATH=/usr/local/Cellar/openssl/1.0.2s -DCMAKE_SHARED_LINKER_FLAGS=-L/usr/local/Cellar/openssl/1.0.2s/lib -DWITH_PROCPS=OFF -DWITH_SUPERCOP=OFF -DOPT_FLAGS=-std=c++11 ..
```


