=head1 NAME

OverallStats.pm   - Parse the output from FindFiles.pm and generate some stats

=head1 SYNOPSIS

use Pathogens::OverallStats;
my $overall_stats = Pathogens::OverallStats->new(
   'find_files_output_file'              => 't/outputfile',
   'user_files_threshold'                => 100,
   'user_total_space_threshold_gigabytes'=> 0.01,
   'users_to_exclude'                    => ['abc','efg']
);
print $overall_stats->report_data;

Optional parameters: user_files_threshold, user_total_space_threshold_gigabytes, users_to_exclude

=cut

package Pathogens::OverallStats;

use Moose;

has 'find_files_output_file'               => ( is => 'rw', isa => 'Str',   required   => 1 );
has 'user_files_threshold'                 => ( is => 'rw', isa => 'Maybe[Int]');
has 'user_total_space_threshold_gigabytes' => ( is => 'rw', isa => 'Maybe[Float]');
has 'users_to_exclude'                     => ( is => 'rw', isa => 'Maybe[Array]');

has 'report_data'                          => ( is => 'rw', isa => 'Str', lazy_build => 1);
has 'total_filesize'                       => ( is => 'rw', isa => 'Int');

sub _build_report_data
{
  my $self = shift;
  
  my %users_files ;
  open(INPUT_FILE, '', $self->find_files_output_file) or die "Couldnt parse input file: ".$self->find_files_output_file. "- $!";
  while(<INPUT_FILE>)
  {
    chomp;
    my @file_details = split(/\t/);
    unless(defined $users_files{$file_details[0]})
    {
      $users_files{$file_details[0]} = {
        filenames => [],
        filesizes => 0
      };
    }
    push(@{$users_files{$file_details[0]}{filenames}}, $file_details[1]);
    $users_files{$file_details[0]}{filesizes} += $file_details[2]/1000000000;
  }

  $self->total_filesize(0);
  print "User\tNo.files\tSize (GB)\n";
  for my $user( keys %users_files)
  {
   my $num_files = @{$users_files{$user}{filenames}};
   $self->total_filesize($users_files{$user}{filesizes} + $self->total_filesize);

   next if $num_files < 100 && $users_files{$user}{filesizes} < 0.01;

   printf("%s\t%10.i\t%.3f\n",$user,$num_files,$users_files{$user}{filesizes});
  }

  $self->total_filesize($total_filesize);
  
}

1;
