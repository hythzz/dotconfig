sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 90 \
--slave /usr/bin/g++ g++ /usr/bin/g++-10 \
--slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-10 \
--slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-10 \
--slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-10 \
--slave /usr/bin/gcov gcov /usr/bin/gcov-dump-10 \
--slave /usr/bin/gcov-dump gcov-dump /usr/bin/gcov-dump-10 \
--slave /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-tool-10 \
--slave /usr/bin/gfortran gfortran /usr/bin/gfortran-10

https://gcc.gnu.org/onlinedocs/libstdc++/manual/abi.html
