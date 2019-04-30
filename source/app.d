import std.stdio;
import hdf5.hdf5;
import dhtslib.sam;
import std.getopt;
import std.array:array;
import std.file:dirEntries,SpanMode;
import std.algorithm:each,map,sort;
import std.algorithm.setops:setIntersection;

string[] tmp_read_names;
string[] filenames;
ulong[string] read_names2fileindex;
bool bam;
void main(string[] args)
{
	GetoptResult res;
	try {
		res = getopt(args, std.getopt.config.bundling,
		"bam|b","Input filtered read file is a bam file.",&bam);
	} catch (GetOptException e){
		stderr.writeln(e.msg);
		stderr.writeln("-h or --help for usage.");
	}
	if(res.helpWanted){
		defaultGetoptPrinter("fast5catcher usage: ./fast5catcher [options] [fast5 dir] [input bam/fastq] [output dir]",res.options);
		return;
	}
	foreach(fn; dirEntries(args[1],SpanMode.depth)) {
		parse_fast5_names(fn);
	}
	tmp_read_names=setIntersection(read_names2fileindex.keys.sort.array,parse_bam_reads(args[2])).array;
	writeln(tmp_read_names);
}

void parse_fast5_names(string fn){
	auto id=H5F.open(fn,H5F_ACC_RDONLY,H5P_DEFAULT);
	H5L.iterate(id, H5Index.Name, H5IterOrder.Inc, &get_object_names);
	tmp_read_names.each!(x=>read_names2fileindex[x]=filenames.length);
	tmp_read_names=[];
	filenames~=fn;
	H5F.close(id);
}

extern(C) static herr_t get_object_names(hid_t loc_id, const char *name, const H5LInfo *linfo, void *opdata)
{
	tmp_read_names~=ZtoString(name);
    // writefln("\nName : %s", ZtoString(name));
    return 0;
}

string[] parse_bam_reads(string fn){
	return SAMFile(fn).all_records.map!(x=>"read_"~x.queryName.idup).array.sort.array;
}
