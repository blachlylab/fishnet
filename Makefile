
all:dub

dhtslib/htslib/hts.c:
	git submodule init
	git submodule update
	cd dhtslib; git submodule init; git submodule update

dhtslib/htslib/libhts.a: dhtslib/htslib/hts.c
	cd dhtslib;cd htslib; make -j 8; 

hdf5-1.8.15-patch1.tar.gz:
	wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.15-patch1/src/hdf5-1.8.15-patch1.tar.gz

hdf5-1.8.15-patch1/README.txt: hdf5-1.8.15-patch1.tar.gz
	tar -xzf hdf5-1.8.15-patch1.tar.gz

hdf5-1.8.15-patch1/bin/libhdf5.a: hdf5-1.8.15-patch1/README.txt
	cd hdf5-1.8.15-patch1; cmake .;make -j 8

dub: hdf5-1.8.15-patch1/bin/libhdf5.a dhtslib/htslib/libhts.a
	dub build --config static --build release