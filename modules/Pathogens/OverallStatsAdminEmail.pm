=head1 NAME

OverallStatsAdminEmail.pm   - Send an email to the Administrators with overall statistics about the filesystem and the files to be deleted

=head1 SYNOPSIS

use Pathogens::OverallStatsAdminEmail;
Pathogens::OverallStatsAdminEmail->new(
	admin_email_addresses => ['abc@example.com','efg@test.com'],
	report_data => 'My report',
	total_filesize => 5.2,
	total_files => 123,
	directory => '/nfs/abc'
);

=cut

package Pathogens::OverallStatsAdminEmail;

use Moose;

has 'admin_email_addresses'   => ( is => 'rw', isa => 'ArrayRef', required => 1);
has 'report_data'             => ( is => 'rw', isa => 'Str',      required => 1);
has 'total_filesize'          => ( is => 'rw', isa => 'Num',      required => 1);
has 'total_files'             => ( is => 'rw', isa => 'Int',      required => 1);
has 'directory'               => ( is => 'rw', isa => 'Str',      required => 1);

sub BUILD
{
  my $self = shift;
	my $body = <<BODY;
	Report on files flagged as candidates for deletion in $self->directory
	Total Number of Files identified: $self->total_files
	Total Filesizes (GB): $self->total_filesizes

	$self->report_data
BODY

	sendmail(-from => "path-help\@sanger.ac.uk",
	           -to => join(',',$self->admin_email_addresses),
	      -subject => "Files for deletion in $self->directory",
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

    close(MAIL);
  }
}

1;
