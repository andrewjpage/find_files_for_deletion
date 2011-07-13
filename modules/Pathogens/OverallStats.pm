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
has 'user_total_space_threshold_gigabytes' => ( is => 'rw', isa => 'Maybe[Num]');
has 'users_to_exclude'                     => ( is => 'rw', isa => 'Maybe[ArrayRef]');

has 'users_files'                          => ( is => 'rw', isa => 'HashRef', lazy_build => 1);
has 'report_data'                          => ( is => 'rw', isa => 'Str',     lazy_build => 1);
has 'total_filesize'                       => ( is => 'rw', isa => 'Num',     lazy_build => 1);


sub _build_total_filesize
{
  my $self = shift;
  my $total_filesize = 0;
  my %user_files = %{$self->users_files};
  
  for my $user ( keys %{$self->users_files})
  {
    $total_filesize += $user_files{$user}{filesizes};
  }

  return $total_filesize;
}

sub _build_report_data
{
  my $self = shift;
  my $report;
  
  $report .= "User\tNo.files\tSize (GB)\n";

  while (my($user, $user_files_data) = each(%{$self->users_files}))
  {
    my $num_files = @{$user_files_data->{filenames}};
    
    next if(( defined $self->user_files_threshold) && ($num_files < $self->user_files_threshold));
    next if(( defined $self->user_total_space_threshold_gigabytes) && $user_files_data->{filesizes} < $self->user_total_space_threshold_gigabytes);
  
    $report .= $user."\t".$num_files."\t".$user_files_data->{filesizes}."\n";
  }
  return $report;
}

sub _build_users_files
{
  my $self = shift;
  my %users_files ;
  
  open(INPUT_FILE, '<', $self->find_files_output_file) or die "Couldnt parse input file: ".$self->find_files_output_file. "- $!";
  while(<INPUT_FILE>)
  {
    chomp;
    my @file_details = split(/\t/);
    next if( $self->_user_should_be_excluded($file_details[0]));
    
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
  close(INPUT_FILE);
  
  return \%users_files;
}

sub _user_should_be_excluded
{
  my($self,$username) = @_;
  return 0 unless(defined $self->users_to_exclude);
  return 1 if(grep {$_ eq $username} @{$self->users_to_exclude});
  
  return 0;
}

1;
