## fast5catcher

### Motivation
Nanopore has moved to a multi-fast5 format for storing nanpore signal.
This provided a much needed improvement in I/O as the previous single-fast5 method
created a large number of very small files. However, now isolating read signal based on 
read mappability, quality, or region is now more diffcult requiring the conversion from 
multi to single fast5, then filtering, then converting back to a multi-fast5.

### Install
We have prebuilt binaries for debian systems under releases.

Or if you prefer you can build fast5catcher. 
You must have dub installed and have htslib minimum requirements installed.

```
git clone https://github.com/blachlylab/fast5catcher.git
cd fast5catcher
make
```

### Usage

Currently only works with bam files  and the multi-fast5 format. Input directory must contain only fast5s.
It will extract the reads present in the bam file from the fast5 input directory and write them to the output directory.
The default number of reads per output file is 4000 reads.

```
fast5catcher usage: ./fast5catcher [options] [fast5 dir] [input bam/fastq] [output dir]
-b       --bam Input filtered read file is a bam file.
-l --readlimit number of reads per output fast5. Default:4000
-h      --help This help information.

./fast5catcher -l 5000 fast5_dir/ test.bam out_dir/
```
