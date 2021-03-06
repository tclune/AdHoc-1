#!/usr/bin/env bash

launch_dir="${PWD}"
if [[ ! -f "${PWD}"/CMakeLists.txt ]]; then
  echo "Missing CMakeLists.txt"
  exit 1
fi

if [[ $1 = "--work-around" ]]; then
   work_around=true
else
   work_around=false
fi

# Exit on error or unset variable.
set -o errexit
set -o nounset

# Check for gfortran & gcc in PATH
if ! type gfortran &> /dev/null; then
  echo "gfortran is not in the PATH."
  exit 10
fi
if ! type gcc &> /dev/null; then
  echo "gcc is not in the PATH."
  exit 20
fi

# Download and unpack MPICH
version=3.1.4
if [[ ! -f "mpich-${version}.tar.gz" ]]; then
   wget http://www.mpich.org/static/downloads/${version}/mpich-${version}.tar.gz
fi
tar xf mpich-${version}.tar.gz

# Build MPICH
mkdir -p mpich-build
pushd mpich-build
  MPI_INSTALL_DIR="${launch_dir}"/prerequisites/installations/mpich/${version}
  ../mpich-${version}/configure --prefix="${MPI_INSTALL_DIR}"
  make install -j 4
popd

# Build CMake issue reproducer
mkdir -p demonstrate-issue
pushd demonstrate-issue

  export MPICC="${MPI_INSTALL_DIR}"/bin/mpicc
  export MPIFC="${MPI_INSTALL_DIR}"/bin/mpif90

  if [[ -x "${MPICC}" && -x "${MPIFC}" ]]; then
    # Demonstrate CMake issue: this prints "MPIEXEC=MPIEXEC_NOTFOUND"
    CC=gcc FC=gfortran cmake ${launch_dir} \
       -DCMAKE_INSTALL_PREFIX=${PWD} \
       -DMPI_C_COMPILER="${MPICC}" \
       -DMPI_Fortran_COMPILER="${MPIFC}"
  else
     exit "MPI is not in the expected location: ${MPI_INSTALL_DIR}"
  fi

# Exit on error or unset variable.
set -o errexit
set -o nounset

# Download and unpack MPICH
version=3.1.4
if [[ ! -d "mpich-${version}" ]]; then
  if [[ ! -f "mpich-${version}.tar.gz" ]]; then
     wget http://www.mpich.org/static/downloads/${version}/mpich-${version}.tar.gz
  fi
  tar xf mpich-${version}.tar.gz
fi

launch_dir="${PWD}"
MPI_INSTALL_DIR="${launch_dir}"/prerequisites/installations/mpich/${version}
if [[ ! -x "${MPI_INSTALL_DIR}/bin/mpif90" ]]; then
  # Build MPICH
  if [[ -d "mpich-build" ]]; then
    rm -rf mpich-build
  fi
  mkdir mpich-build
  pushd mpich-build
    ../mpich-${version}/configure --prefix="${MPI_INSTALL_DIR}"
    make install -j 4
  popd
fi
export MPICC="${MPI_INSTALL_DIR}"/bin/mpicc
export MPIFC="${MPI_INSTALL_DIR}"/bin/mpif90
if [[ ! -x "${MPICC}" ]]; then
  echo "mpicc is not in the expected location: ${MPICC}"
  exit 1
fi
if [[ ! -x "${MPIFC}" ]]; then
  echo "mpicc is not in the expected location: ${MPIFC}"
  exit 1
fi

if [[ "${work_around}" == "true"  ]]; then
  # If this block is not executed, the CMake invocation below will set MPIEXEC to
  # the first mpiexec in the PATH or to NOT_FOUND if no mpiexec is in the PATH
  if [[ -z "${PATH}" ]]; then
    echo "PATH=\"${MPI_INSTALL_DIR}\"/bin"
    export PATH="${MPI_INSTALL_DIR}"/bin
  else
    echo "PATH=\"${MPI_INSTALL_DIR}\"/bin:\"${PATH}]\""
    export PATH="${MPI_INSTALL_DIR}"/bin:"${PATH}"
  fi
fi

# Build CMake issue reproducer
if [[ -d "demonstrate-issue"  ]]; then
  rm -rf demonstrate-issue
fi
mkdir demonstrate-issue
pushd demonstrate-issue

  echo "CC=${CC:-${MPICC}} FC=${FC:-${MPIFC}} cmake ${launch_dir} \\"
  echo "   -DCMAKE_INSTALL_PREFIX=${PWD} \\"
  echo "   -DMPI_C_COMPILER=${MPICC} \\"
  echo "   -DMPI_Fortran_COMPILER=${MPIFC}"


  CC=${CC:-${MPICC}} FC=${FC:-${MPIFC}} cmake ${launch_dir} \
     -DCMAKE_INSTALL_PREFIX=${PWD} \
     -DMPI_C_COMPILER="${MPICC}" \
     -DMPI_Fortran_COMPILER="${MPIFC}"

popd
echo "Done"
