c:\msys64\mingw64\bin\gcc.exe -march=native -mtune=native -mdll -O -Wall -Ic:\python37-w64\include -Ic:\python37-w64\include -c alt_bn128_wrap.cpp -o build\temp.win-amd64-3.7\Release\alt_bn128_wrap.o -std=c++11 -Wno-sign-compare -Wno-delete-non-virtual-dtor -Wno-unused-variable -DCURVE_ALT_BN128 -DBN_SUPPORT_SNARK=1 -DMONTGOMERY_OUTPUT -DNO_PROCPS
c:\msys64\mingw64\bin\g++.exe -shared -s libff\*.obj build\temp.win-amd64-3.7\Release\alt_bn128_wrap.o build\temp.win-amd64-3.7\Release\_alt_bn128.cp37-win_amd64.def -Lc:\python37-w64\libs -Lc:\python37-w64\PCbuild\amd64 -lpython37 -o build\lib.win-amd64-3.7\libsnark\_alt_bn128.cp37-win_amd64.pyd -static-libgcc -Wl,-Bstatic -lgmpxx -Wl,-Bstatic -lgmp
c:\python37-w64\python setup-win32.py install
