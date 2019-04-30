
all:hdf5-build

hdf5-1.8.15-patch1.tar.gz:
	wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.15-patch1/src/hdf5-1.8.15-patch1.tar.gz

unzip:hdf5-1.8.15-patch1.tar.gz
	tar -xzf hdf5-1.8.15-patch1.tar.gz

hdf5-build:unzip
	cd hdf5-1.8.15-patch1; cmake;make -j 8
