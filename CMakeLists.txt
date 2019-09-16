cmake_minimum_required(VERSION 3.10)
cmake_policy(VERSION 3.14)
project(python-libsnark)

include(cmake/libsnark.cmake)

add_subdirectory(depends)

find_package (Python3 COMPONENTS Interpreter Development)

#find_package(PythonInterp 3.5 REQUIRED)
#find_package(PythonLibs 3.5 REQUIRED)

# need this for ${PYTHON_EXTENSION_MODULE_SUFFIX} -- actually this determines the
# suffix for the system python, not for python3...
include(cmake/FindPythonExtensions.cmake)

find_package(SWIG)
include(UseSWIG)

set_property(SOURCE libsnark.i PROPERTY CPLUSPLUS ON)

# TODO set additional dependencies
# TODO set swig builtin flag
swig_add_library(libsnark
                 TYPE SHARED
                 LANGUAGE python
                 NO_PROXY
                 SOURCES libsnark.i)

set_property(TARGET libsnark PROPERTY SWIG_INCLUDE_DIRECTORIES ${DEPENDS_DIR}/libsnark)
set_property(TARGET libsnark PROPERTY SUFFIX ".so")
set_property(TARGET libsnark PROPERTY SWIG_GENERATED_INCLUDE_DIRECTORIES ${DEPENDS_DIR}/libsnark;${DEPENDS_DIR}/libsnark/depends/libfqfft;${DEPENDS_DIR}/libsnark/depends/libff;${OPENSSL_INCLUDE_DIR};${Python3_INCLUDE_DIRS};${GMP_INCLUDE_DIR})

#add_library(libsnark MODULE libsnark.cpp)
#python_extension_module(libsnark)
    
swig_link_libraries(libsnark snark ${Python3_LIBRARIES})


#target_include_directories(
#  libsnark
#
#  PUBLIC
#  ${DEPENDS_DIR}/libsnark
#  ${DEPENDS_DIR}/libsnark/depends/libfqfft
#  ${DEPENDS_DIR}/libsnark/depends/libff  
#  ${OPENSSL_INCLUDE_DIR}
#)


