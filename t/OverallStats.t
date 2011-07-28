#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 7;
    use_ok('Pathogens::OverallStats');
}

ok my $overall_stats = Pathogens::OverallStats->new(
   'find_files_output_file'              => 't/data/overall_stats_input_file'
), 'initialize';

is $overall_stats->total_filesize, 10, 'total filesize';

my $expected_report_data = 'User	No.files	Size (GB)
abc	9	3
efg	17	7
';
is $overall_stats->report_data, $expected_report_data, 'report data';


# exclude certain users
my @users_to_exclude = ('abc','root');
ok $overall_stats = Pathogens::OverallStats->new(
   'find_files_output_file'              => 't/data/overall_stats_input_file',
   'users_to_exclude'                    => \@users_to_exclude
), 'initialize';

is $overall_stats->total_filesize, 7, 'total filesize';

$expected_report_data = 'User	No.files	Size (GB)
efg	17	7
';
is $overall_stats->report_data, $expected_report_data, 'report data';

