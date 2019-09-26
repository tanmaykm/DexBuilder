# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "DexBuilder"
version = v"2.19.0"

# Collection of sources required to build DexBuilder
sources = [
    "https://golang.org/dl/go1.12.4.linux-amd64.tar.gz" =>
    "d7d1f1f88ddfe55840712dc1747f37a790cbcaa448f6c9cf51bbe10aa65442f5",

    "https://github.com/dexidp/dex/archive/v2.19.0.tar.gz" =>
    "321d28b863fbaa49de3e5a3b1ffbf8d270c77905cffae7af926737d0a6cfd8a5",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
export GOPATH=$WORKSPACE/gopath
export GOCACHE=$WORKSPACE/gocache
mkdir -p $GOPATH/src/github.com/dexidp
mkdir -p $GOCACHE
ln -fs $WORKSPACE/srcdir/dex-2.19.0 $GOPATH/src/github.com/dexidp/dex
export PATH=$PATH:$WORKSPACE/srcdir/go/bin
go get github.com/bitnami/bcrypt-cli
cd $GOPATH/src/github.com/dexidp/dex
make
mkdir -p $prefix/bin
mkdir -p $prefix/lib
cp $GOPATH/src/github.com/dexidp/dex/bin/* $prefix/bin/
cp $GOPATH/bin/bcrypt-cli $prefix/bin/
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:musl),
    Linux(:x86_64, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    ExecutableProduct(prefix, "dex", :dex),
    ExecutableProduct(prefix, "grpc-client", :grpcclient),
    ExecutableProduct(prefix, "bcrypt-cli", :bcryptcli)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

