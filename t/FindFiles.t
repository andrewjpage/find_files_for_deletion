#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 29;
    use_ok('Pathogens::FindFiles');
}

ok my $find_files = Pathogens::FindFiles->new(
   output_file     => 't/data/tmp_output', 
   directory       => 't/data', 
   regex           => '(\.out$)|(\.dribble\.)|(\.err$)|(\.o$)|(\.e$)|(\~$)|(\/#)|(\.log$)|(\/LastGraph)|(\/Roadmaps)|(\/Sequences\/)|(ICORN)|(\/IMAGE)|(\/fasta\/)|(\/(t)?blast.?\/)|(tmp)|(\_2$)', 
   exclude         => '.snapshot'
 ), 'initialize';

ok open FILE, 't/data/tmp_output' or die $!, 'Results file can be opened';
my @expected_filenames = (
  't/data/tmp_output'              ,
  't/data/datadir/#abc'            ,
  't/data/datadir/abc.dribble.efg' ,
  't/data/datadir/abc.e'           ,
  't/data/datadir/abc.efg~'        ,
  't/data/datadir/abc.err'         ,
  't/data/datadir/abc.log'         ,
  't/data/datadir/abc.o'           ,
  't/data/datadir/abc.out'         ,
  't/data/datadir/abc_2'           ,
  't/data/datadir/blast/.empty'    ,
  't/data/datadir/fasta/.empty'    ,
  't/data/datadir/ICORN'           ,
  't/data/datadir/ICORN/.empty'    ,
  't/data/datadir/IMAGE'           ,
  't/data/datadir/IMAGE/.empty'    ,
  't/data/datadir/IMAGE2'          ,
  't/data/datadir/IMAGE2/.empty'   ,
  't/data/datadir/LastGraph'       ,
  't/data/datadir/LastGraph/.empty',
  't/data/datadir/Roadmaps'        ,
  't/data/datadir/Roadmaps/.empty' ,
  't/data/datadir/Sequences/.empty',
  't/data/datadir/tblastn/.empty'  ,
  't/data/datadir/tmp'             ,
  't/data/datadir/tmp/.empty'
);

my $line_count = 0;
while(<FILE>)
{
  chomp;
  my($username, $filename, $filesize) = split("\t");
  is $filename, $expected_filenames[$line_count], 'file correctly found in output: '.$expected_filenames[$line_count];
  $line_count++;
}