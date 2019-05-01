import std.stdio;
import hdf5.hdf5;
import dhtslib.sam;
import std.getopt;
import std.array:array;
import std.file:dirEntries,SpanMode;
import std.algorithm:each,map,sort;
import std.algorithm.setops:setIntersection;
import std.conv:to;
import std.file:mkdirRecurse;

string[] tmp_read_names;
string[] filenames;
ulong[string] read_names2fileindex;
bool bam;
int readlimit=4000;
int readcount=0;
hid_t outfile;
int outfile_lab=0;
void main(string[] args)
{
	GetoptResult res;
	try {
		res = getopt(args, std.getopt.config.bundling,
		"bam|b","Input filtered read file is a bam file.",&bam,
		"readlimit|l","number of reads per output fast5. Default:4000",&readlimit);
	} catch (GetOptException e){
		stderr.writeln(e.msg);
		stderr.writeln("-h or --help for usage.");
	}
	if(res.helpWanted){
		defaultGetoptPrinter("fast5catcher usage: ./fast5catcher [options] [fast5 dir] [input bam/fastq] [output dir]",res.options);
		return;
	}else if(args.length==1){
		defaultGetoptPrinter("fast5catcher usage: ./fast5catcher [options] [fast5 dir] [input bam/fastq] [output dir]",res.options);
		return;
	}else if(args.length!=4){
		stderr.writeln("fast5catcher: Incorrect number of inputs!");
		defaultGetoptPrinter("fast5catcher usage: ./fast5catcher [options] [fast5 dir] [input bam/fastq] [output dir]",res.options);
		return;
	}

	// get all readnames from fast5s
	foreach(fn; dirEntries(args[1],SpanMode.depth)) {
		parse_fast5_names(fn);
	}
	stderr.writeln("[fast5catcher]: parsed fast5 read names");

	//intersect with bamfile read names
	tmp_read_names=setIntersection(read_names2fileindex.keys.sort.array,parse_bam_reads(args[2])).array;

	stderr.writeln("[fast5catcher]: intersected with filtered read name file");

	//make output dir and first output file
	mkdirRecurse(args[3]);
	outfile=H5F.create(args[3]~"/"~outfile_lab.to!string~".fast5",H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

	read_names2fileindex.rehash;

	// resort read name array by origin file
	tmp_read_names=tmp_read_names.sort!((a,b)=>read_names2fileindex[a]<read_names2fileindex[b]).array;

	//  remap read name array to origin file
	auto readfiles=tmp_read_names.map!(x=>filenames[read_names2fileindex[x]]);
	// readfiles.writeln;
	string prev;
	hid_t infile=-1;
	stderr.writeln("[fast5catcher]: writing files");
	foreach(read;tmp_read_names){

		//if next origin file is different
		if(prev!=readfiles.front){

			//if not first close previous file
			if(infile!=-1){
				H5F.close(infile);
			}
			//open new file
			infile=H5F.open(readfiles.front,H5F_ACC_RDONLY,H5P_DEFAULT);
		}

		//get output file id and copy read data
		outfile=verify_file_limit(outfile,args[3]);
		copyReadData(read,infile,outfile);
		prev=readfiles.front;
		readfiles.popFront;
		readcount++;
	}
}

/**
 * 	Iterate over a fast5 file and discover all read names.
 * 	We must write this to a global tmp array tmp_read_names from H5L.iterate.
 * 	TODO: Find better solution
 */
void parse_fast5_names(string fn){
	auto id=H5F.open(fn,H5F_ACC_RDONLY,H5P_DEFAULT);
	H5L.iterate(id, H5Index.Name, H5IterOrder.Inc, &get_object_names);
	tmp_read_names.each!(x=>read_names2fileindex[x]=filenames.length);
	tmp_read_names=[];
	filenames~=fn;
	H5F.close(id);
}

/**
 *	Get the read names from fast5
 */
extern(C) static herr_t get_object_names(hid_t loc_id, const char *name, const H5LInfo *linfo, void *opdata)
{
	tmp_read_names~=ZtoString(name);
    // writefln("\nName : %s", ZtoString(name));
    return 0;
}

/**
 *	Get the read names from bam file.
 */
string[] parse_bam_reads(string fn){
	return SAMFile(fn).all_records.map!(x=>"read_"~x.queryName.idup).array.sort.array;
}

/**
 *	Ensure that output files have less reads per file than the limit or create a new file.
 */
hid_t verify_file_limit(hid_t cur,string dir){
	if(readcount>=readlimit){
		H5F.close(outfile);
		outfile_lab++;
		cur=H5F.create(dir~"/"~outfile_lab.to!string~".fast5",H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
		readcount=0;
	}
	return cur;
}

/**
 *	copy read from input file to output file
 */
void copyReadData(string read,hid_t from, hid_t to){
	H5O.copy(from,"/"~read,to,"/"~read,H5P_DEFAULT,H5P_DEFAULT);
}
