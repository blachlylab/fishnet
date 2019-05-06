## fishnet

```  ______ _     _                _   
 |  ____(_)   | |              | |  
 | |__   _ ___| |__  _ __   ___| |_ 
 |  __| | / __| '_ \| '_ \ / _ \ __|
 | |    | \__ \ | | | | | |  __/ |_ 
 |_|    |_|___/_| |_|_| |_|\___|\__|

 o - - o - - o - - o - - o - - o
  \   / \   / \   / \   / \   /
   \ /   \ /   \ /   \ /   \ /
    X     X     X ><> X     X
   / \   / \   / \   / \   / \
  /   \ /   \ /   \ /   \ /   \
 X     X ><> X     X     X ><> X
  \   / \   / \   / \   / \   /
```

### Motivation
Nanopore has moved to a multi-fast5 format for storing nanpore signal.
This provided a much needed improvement in I/O as the previous single-fast5 method
created a large number of very small files. However, now isolating read signal based on 
read mappability, quality, or region is now more diffcult requiring the conversion from 
multi to single fast5, then filtering, then converting back to a multi-fast5. fishnet takes a 
filtered input BAM file and a directory of fast5s and outputs fast5s containing reads 
that were found in the BAM file.

### Install
We have prebuilt binaries for debian systems under releases.

Or if you prefer you can build fishnet. 
You must have dub installed and have htslib minimum requirements installed.

```
git clone https://github.com/blachlylab/fishnet.git
cd fishnet
make
```

### Usage

Currently only works with bam files  and the multi-fast5 format. Input directory must contain only fast5s.
It will extract the reads present in the bam file from the fast5 input directory and write them to the output directory.
The default number of reads per output file is 4000 reads.

```
fishnet usage: ./fishnet [options] [fast5 dir] [input bam/fastq] [output dir]
-b       --bam Input filtered read file is a bam file.
-l --readlimit number of reads per output fast5. Default:4000
-h      --help This help information.

./fishnet -l 5000 fast5_dir/ test.bam out_dir/
```
