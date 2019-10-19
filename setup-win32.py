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

setup(name = "python-libsnark",
      version = "0.3.2",
      description='Python bindings for a restricted subset of libsnark',
      author='Meilof Veeningen',
      author_email='meilof@gmail.com',
      license='MIT',
      url='https://github.com/meilof/python-libsnark',
      packages = ["libsnark"],
      package_dir = {"libsnark": "."},
      ext_modules = [Extension("libsnark._alt_bn128", 
                     ["alt_bn128_ainit.cpp", "alt_bn128_g1.cpp", "alt_bn128_g2.cpp", "alt_bn128_pairing.cpp", "alt_bn128_pp.cpp", "double.cpp", 
                      "profiling.cpp", "utils.cpp", "alt_bn128_wrap.cpp"], 
                     extra_compile_args=["-std=c++11", "-Wno-sign-compare", "-Wno-delete-non-virtual-dtor",
                        "-Wno-unused-variable", "-DCURVE_ALT_BN128", 
                        "-DBN_SUPPORT_SNARK=1", "-DMONTGOMERY_OUTPUT", "-DNO_PROCPS"],
                     libraries=[], 
                     extra_link_args = ["-static-libgcc", "-Wl,-Bstatic", "-lgmpxx", "-Wl,-Bstatic", "-lgmp"],
                     swig_opts=["-c++"])])
