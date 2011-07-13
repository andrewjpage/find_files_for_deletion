#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 4;
    use_ok('Pathogens::OverallStats');
}

ok my $overall_stats = Pathogens::OverallStats->new(
   'find_files_output_file'              => 't/data/overall_stats_input_file'
), 'initialize';

is $overall_stats->total_filesize, 9.000000408, 'total filesize';

my $expected_report_data = 'User	No.files	Size (GB)
abc	9	3
efg	17	6.000000408
';
is $overall_stats->report_data, $expected_report_data, 'report data';
