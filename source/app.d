import std.stdio;
import hdf5.hdf5;
import dhtslib.sam;
import std.file:dirEntries,SpanMode;
import std.algorithm:each;
import std.algorithm.setops:setIntersection;

string[] tmp_read_names;
string[] filenames;
ulong[string] read_names2fileindex;
void main(string[] args)
{
	// parse_fast5_names(args[1]);
	foreach(fn; dirEntries(args[1],SpanMode.depth)) {
		parse_fast5_names(fn);
	}
	filenames.writeln;
	read_names2fileindex.writeln;
}

void parse_fast5_names(string fn){
	auto id=H5F.open(fn,H5F_ACC_RDWR,H5P_DEFAULT);
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
