
#!/bin/bash

set -e
set -x
mkdir -p objects

# --cuda-gpu-arch=gfx900

hipcc -fgpu-rdc -fPIC -g -O -x hip -std=c++14 -c ./file1.hip -o objects/file1.o
hipcc -fgpu-rdc -fPIC -g -O -x hip -std=c++14 -c ./file2.hip -o objects/file2.o
hipcc -fgpu-rdc -fPIC -g -O -x hip -std=c++14 -c ./file3.hip -o objects/file3.o

# make a static library from 1, 2, and 3
# check with clang-ar
rm -f libHIPSeparateLibA.a
ar qc libHIPSeparateLibA.a objects/file1.o objects/file2.o objects/file3.o

hipcc -fgpu-rdc -fPIC -g -O -x hip -std=c++14 -c ./file4.cxx -o objects/file4.o
hipcc -fgpu-rdc -fPIC -g -O -x hip -std=c++14 -c ./file5.cxx -o objects/file5.o


hipcc --hip-link -fgpu-rdc -shared -Wl,-soname,libHIPCallsCorrectA.so -o libHIPCallsCorrectA.so objects/file4.o objects/file5.o libHIPSeparateLibA.a
hipcc --hip-link -fgpu-rdc -shared -Wl,-soname,libHIPCallsCorrectB.so -o libHIPCallsCorrectB.so @objects.rsp libHIPSeparateLibA.a
hipcc --hip-link -fgpu-rdc -shared -Wl,-soname,libHIPCallsFail.so -o libHIPCallsFail.so objects/file4.o objects/file5.o @archives.rsp
