# setup.py
import distutils
from distutils.core import setup, Extension
import os

print("* To update the wrapper, use swig -python -c++ -o alt_bn128_wrap.cpp libsnark.i")
#os.system("swig -python -c++ -o alt_bn128_wrap.cpp libsnark.i")

# cannot use .i file below because distutils doesn't understand c++ wrappers
# USE_ASM breaks stuff on mac os

setup(name = "python-libsnark",
      version = "0.3",
      description='Python bindings for a restricted subset of libsnark',
      author='Meilof Veeningen',
      author_email='meilof@gmail.com',
      url='https://github.com/meilof/python-libsnark',
      packages = ["libsnark"],
      package_dir = {"libsnark": "."},
      ext_modules = [Extension("libsnark._alt_bn128", ["alt_bn128_wrap.cpp"], extra_compile_args=["-std=c++11", "-Wno-sign-compare", "-Wno-delete-non-virtual-dtor", "-Wno-unused-variable", "-DCURVE_ALT_BN128", "-DBINARY_OUTPUT", "-DBN_SUPPORT_SNARK=1", "-DMONTGOMERY_OUTPUT", "-DNO_PROCPS"], libraries=["snark", "ff", "gmpxx"], extra_link_args=['-static'], swig_opts=["-c++"])])
