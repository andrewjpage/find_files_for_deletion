=head1 NAME

OverallStatsAdminEmail.pm   - Send an email to the Administrators with overall statistics about the filesystem and the files to be deleted

=head1 SYNOPSIS

use Pathogens::OverallStatsAdminEmail;
Pathogens::OverallStatsAdminEmail->new(
	admin_email_addresses => ['abc@example.com','efg@test.com'],
	report_data           => 'My report',
	total_filesize        => 5.2,
	total_files           => 123,
	directory             => '/nfs/abc',
	email_from_address    => 'example@example.com'
);

=cut

package Pathogens::OverallStatsAdminEmail;

use Moose;
use POSIX;

has 'admin_email_addresses'   => ( is => 'rw', isa => 'ArrayRef', required => 1);
has 'report_data'             => ( is => 'rw', isa => 'Str',      required => 1);
has 'total_filesize'          => ( is => 'rw', isa => 'Num',      required => 1);
has 'total_files'             => ( is => 'rw', isa => 'Int',      required => 1);
has 'directory'               => ( is => 'rw', isa => 'Str',      required => 1);
has 'email_from_address'      => ( is => 'rw', isa => 'Str',      required => 1);

sub BUILD
{
  my $self = shift;
  my $total_files =$self->total_files;
  my $total_filesizes= ceil($self->total_filesize);
  my $directory = $self->directory;
  my $report_data = $self->report_data;

	my $body = <<BODY;
Report on files flagged as candidates for deletion in: $directory

Total Number of Files identified: $total_files
Total Filesizes (GB): $total_filesizes

$report_data
BODY
	sendmail(-from => $self->email_from_address,
	           -to => join(',', @{$self->admin_email_addresses}),
	      -subject => "Files for deletion in $directory",
	         -body => $body);

}

sub sendmail {
  my %args = @_;
  my ($from, $to, $subject, $body) = @args{qw(-from -to -subject -body)};
   
  unless(open (MAIL, "|/usr/sbin/sendmail -t")) {
    warn "Error starting sendmail: $!";
  }
  else{
    print MAIL "From: $from\n";
    print MAIL "To: $to\n";
    print MAIL "Subject: $subject\n\n";
    print MAIL $body;

    if (close(MAIL)) {
    }
    else {
      warn "Failed to send mail: $!";
    }
  }
}

1;
