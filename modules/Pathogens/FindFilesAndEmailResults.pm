=head1 NAME

FindFilesAndEmailResults.pm   - Driver module for finding files and emailing results to admins and individual users

=head1 SYNOPSIS

use Pathogens::FindFilesAndEmailResults;
Pathogens::FindFilesAndEmailResults->new(
  admin_email_addresses                => ['abc@example.com','efg@example.com'],
  email_from_address                   => 'noreply@example.com',
  directory                            => '/nfs',
  output_file                          => 'myfile',
  regex                                => '(\.out$)|(\.log\.)',
  exclude                              => 'snapshot',
  user_files_threshold                 => 100,
  user_total_space_threshold_gigabytes => 0.01,
  users_to_exclude                     => ['abc','efg']
);

=cut

package Pathogens::FindFilesAndEmailResults;

use Moose;
use Pathogens::ConfigSettings;
use Pathogens::FindFiles;
use Pathogens::OverallStats;
use Pathogens::OverallStatsAdminEmail;
use Pathogens::UserFilesEmail;

has 'admin_email_addresses'                => ( is => 'rw', isa => 'ArrayRef',        required => 1);
has 'email_from_address'                   => ( is => 'rw', isa => 'Str',             required => 1);
has 'directory'                            => ( is => 'rw', isa => 'Str',             required => 1);
has 'output_file'                          => ( is => 'rw', isa => 'Str',             required => 1);
has 'regex'                                => ( is => 'rw', isa => 'Str',             required => 1);
has 'exclude'                              => ( is => 'rw', isa => 'Maybe[Str]',      required => 1);
has 'user_files_threshold'                 => ( is => 'rw', isa => 'Maybe[Int]',      required => 1);
has 'user_total_space_threshold_gigabytes' => ( is => 'rw', isa => 'Maybe[Num]',      required => 1);
has 'users_to_exclude'                     => ( is => 'rw', isa => 'Maybe[ArrayRef]', required => 1);

sub BUILD
{
  my $self = shift;

  Pathogens::FindFiles->new(
    directory       => $self->directory,
    output_file     => $self->output_file,
    regex           => $self->regex,
    exclude         => $self->exclude
  );

	my $overall_stats = Pathogens::OverallStats->new(
	   find_files_output_file               => $self->output_file,
	   user_files_threshold                 => $self->user_files_threshold,
	   user_total_space_threshold_gigabytes => $self->user_total_space_threshold_gigabytes,
	   users_to_exclude                     => $self->users_to_exclude
	);

	Pathogens::OverallStatsAdminEmail->new(
		admin_email_addresses => $self->admin_email_addresses,
		report_data => $overall_stats->report_data,
		total_filesize => $overall_stats->total_filesize,
		total_files => $overall_stats->total_files,
		directory => $self->directory,
		email_from_address => $self->email_from_address
	);
  
  my %users_files = %{$overall_stats->users_files};
  
	for my $username (keys  %{$overall_stats->users_files})
	{
    Pathogens::UserFilesEmail->new(
      email_to_address    => $username,
      email_from_address  => $self->email_from_address,
      file_names          => $users_files{$username}{filenames},
      total_filesize      => $users_files{$username}{filesizes},
      directory           => $self->directory
    );
  }
}

1;
