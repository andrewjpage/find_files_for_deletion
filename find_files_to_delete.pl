#!/usr/bin/env perl

=head1 NAME

find_files_to_delete.pl

=head1 SYNOPSIS

perl find_files_to_delete.pl -e test -d t/ -o output

=head1 DESCRIPTION

This will look for files which can usually be deleted. 
It outputs a tab delimited file with:
username, file with fullpath, size of file

=head1 CONTACT

path-help@sanger.ac.uk

=head1 METHODS

=cut

BEGIN { unshift(@INC, './modules') }
use strict;
use warnings;
use File::Find;
use Getopt::Long;
use Pathogens::ConfigSettings;
use Pathogens::FindFiles;
use Pathogens::OverallStats;
use Pathogens::OverallStatsAdminEmail;

my $DIRECTORY;
my $OUTPUT_FILE;
my $ENVIRONMENT;

GetOptions ( 'environment|e=s'  => \$ENVIRONMENT,
             'directory|d=s'    => \$DIRECTORY,
             'output_file|o=s'  => \$OUTPUT_FILE
);

$ENVIRONMENT or die <<USAGE;
Usage: $0 [options]
This will look for files which can usually be deleted

./find_files_to_delete.pl -e test --directory /path_to/directory -o my_output_file
 Options:
     --environment     Production or Test
     --directory       The root directory to use
     --output_file     The filename for the raw list of found files

USAGE
;

my %config_settings = %{Pathogens::ConfigSettings->new(environment => $ENVIRONMENT, filename => 'config.yml')->settings()};

# values passed in so use these instead of the places to search values in the config files
#TODO dry this out
if(( defined $DIRECTORY) && ( defined $OUTPUT_FILE))
{
  Pathogens::FindFiles->new(
    output_file     => $OUTPUT_FILE, 
    directory       => $DIRECTORY, 
    regex           => $config_settings{default}{regex}, 
    exclude         => $config_settings{default}{exclude}
  );

	my $overall_stats = Pathogens::OverallStats->new(
	   find_files_output_file               => $OUTPUT_FILE,
	   user_files_threshold                 => $config_settings{default}{user_files_threshold},
	   user_total_space_threshold_gigabytes => $config_settings{default}{user_total_space_threshold_gigabytes},
	   users_to_exclude                     => $config_settings{default}{users_to_exclude}
	);
	
		
	Pathogens::OverallStatsAdminEmail->new(
		admin_email_addresses => $config_settings{default}{admin_email_addresses},
		report_data => $overall_stats->report_data,
		total_filesize => $overall_stats->total_filesize,
		total_files => $overall_stats->total_files,
		directory => $DIRECTORY
	);

}
else
{
  # run in bulk from the config file
  for my $place_to_search ( @{$config_settings{default}{places_to_search}} )
  {
    Pathogens::FindFiles->new(
      directory       => $config_settings{$place_to_search}{root_directory}, 
      output_file     => $config_settings{$place_to_search}{output_file},
      regex           => ($config_settings{$place_to_search}{regex}   || $config_settings{default}{regex}), 
      exclude         => ($config_settings{$place_to_search}{exclude} || $config_settings{default}{exclude})
    );

		my $overall_stats = Pathogens::OverallStats->new(
		   find_files_output_file               => $config_settings{$place_to_search}{output_file},
		   user_files_threshold                 => $config_settings{default}{user_files_threshold},
		   user_total_space_threshold_gigabytes => $config_settings{default}{user_total_space_threshold_gigabytes},
		   users_to_exclude                     => $config_settings{default}{users_to_exclude}
		);
		
		Pathogens::OverallStatsAdminEmail->new(
			admin_email_addresses => $config_settings{default}{admin_email_addresses},
			report_data => $overall_stats->report_data,
			total_filesize => $overall_stats->total_filesize,
			total_files => $overall_stats->total_files,
			directory => $config_settings{$place_to_search}{root_directory}
		);

  }
}


