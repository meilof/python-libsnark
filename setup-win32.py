# setup.py
import setuptools
import distutils
from distutils.core import setup, Extension
import os

import distutils.cygwinccompiler
distutils.cygwinccompiler.get_msvcr = lambda: []

print("* To update the wrapper, use swig -python -c++ -o alt_bn128_wrap.cpp libsnark.i")
#os.system("swig -python -c++ -o alt_bn128_wrap.cpp libsnark.i")

# cannot use .i file below because distutils doesn't understand c++ wrappers
# USE_ASM breaks stuff on mac os
# , extra_link_args=['-static'] on macos makes sense?


# copy respective files from libsnark to current directory
# copy headers installed by libsnark into current directory
# build
# /c/Python39/python setup-win32.py build -c mingw32
# /c/Python39/python setup-win32.py install
# /c/Python39/python setup-win32.py bdist_egg


setup(name = "python-libsnark",
      version = "0.3.3",
      description='Python bindings for a restricted subset of libsnark',
      author='Meilof Veeningen',
      author_email='meilof@gmail.com',
      license='MIT',
      url='https://github.com/meilof/python-libsnark',
      packages = ["libsnark"],
      package_dir = {"libsnark": "."},
      ext_modules = [Extension("libsnark._alt_bn128", 
                     ["alt_bn128_ainit.cpp", 
                      "alt_bn128_g1.cpp", 
                      "alt_bn128_g2.cpp", 
                      "alt_bn128_pairing.cpp", 
                      "alt_bn128_pp.cpp", 
                      "double.cpp", 
                      "profiling.cpp", 
                      "utils.cpp", 
                      "serialization.cpp",
                      "alt_bn128_wrap.cpp"], 
                     extra_compile_args=["-I.", "-std=c++14", "-Wno-sign-compare", "-Wno-delete-non-virtual-dtor",
                        "-Wno-unused-variable", "-DCURVE_ALT_BN128", "-DNO_PT_COMPRESSION=1",
                        "-DBN_SUPPORT_SNARK=1", "-DMONTGOMERY_OUTPUT", "-DNO_PROCPS"],
                     libraries=[], 
                     extra_link_args = ["-static-libgcc", "-Wl,-Bstatic", "-lgmpxx", "-Wl,-Bstatic", "-lgmp", "-lboost_iostreams-mt"],
                     swig_opts=["-c++"])])
