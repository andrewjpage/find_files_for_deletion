#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most ;
    use_ok('Pathogens::FindFiles');
}

ok my $find_files = Pathogens::FindFiles->new(
   output_file     => 't/data/tmp_output', 
   directory       => 't/data', 
   regex           => '(\.out$)|(\.dribble\.)|(\.err$)|(\.o$)|(\.e$)|(\~$)|(\/#)|(\.log$)|(\/LastGraph)|(\/Roadmaps)|(\/Sequences\/)|(ICORN)|(\/IMAGE)|(\/fasta\/)|(\/(t)?blast.?\/)|(tmp)|(\_2$)', 
   exclude         => '.directory_to_ignore'
 ), 'initialize';



my %expected_filenames = (
  't/data/tmp_output'              => 1 ,
  't/data/datadir/#abc'            => 1 ,
  't/data/datadir/abc.dribble.efg' => 1 ,
  't/data/datadir/abc.e'           => 1 ,
  't/data/datadir/abc.efg~'        => 1 ,
  't/data/datadir/abc.err'         => 1 ,
  't/data/datadir/abc.log'         => 1 ,
  't/data/datadir/abc.o'           => 1 ,
  't/data/datadir/abc.out'         => 1 ,
  't/data/datadir/abc_2'           => 1 ,
  't/data/datadir/blast/.empty'    => 1 ,
  't/data/datadir/fasta/.empty'    => 1 ,
  't/data/datadir/ICORN'           => 1 ,
  't/data/datadir/ICORN/.empty'    => 1 ,
  't/data/datadir/IMAGE'           => 1 ,
  't/data/datadir/IMAGE/.empty'    => 1 ,
  't/data/datadir/IMAGE2'          => 1 ,
  't/data/datadir/IMAGE2/.empty'   => 1 ,
  't/data/datadir/LastGraph'       => 1 ,
  't/data/datadir/LastGraph/.empty'=> 1 ,
  't/data/datadir/Roadmaps'        => 1 ,
  't/data/datadir/Roadmaps/.empty' => 1 ,
  't/data/datadir/Sequences/.empty' => 1 ,
  't/data/datadir/tblastn/.empty'  => 1 ,
  't/data/datadir/tmp'             => 1 ,
  't/data/datadir/tmp/.empty'      => 1 
);

my $line_count = 0;

open( my $fh, '-|', 'sort t/data/tmp_output');
while(<$fh>)
{
  chomp;
  my($username, $filename, $filesize) = split("\t");
  ok(defined( $expected_filenames{$filename}), 'file correctly found in output');
  $line_count++;
}

done_testing();