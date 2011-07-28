=head1 NAME

UserFilesEmail.pm   - Send an email to the Administrators with overall statistics about the filesystem and the files to be deleted

=head1 SYNOPSIS

use Pathogens::UserFilesEmail;
Pathogens::UserFilesEmail->new(
  email_to_address    => 'abc@example.com',
  email_from_address  => 'efg@example.com',
  file_names          => ['/nfs/abc.txt', '/nfs/efg.doc'],
  total_filesize      => 123.456,
  directory           => '/nfs'
);

=cut

package Pathogens::UserFilesEmail;

use Moose;
use POSIX;

has 'email_to_address'        => ( is => 'rw', isa => 'Str',      required => 1);
has 'email_from_address'      => ( is => 'rw', isa => 'Str',      required => 1);
has 'file_names'              => ( is => 'rw', isa => 'ArrayRef', required => 1);
has 'total_filesize'          => ( is => 'rw', isa => 'Num',      required => 1);
has 'directory'               => ( is => 'rw', isa => 'Str',      required => 1);


sub BUILD
{
  my $self = shift;
  my $total_files = @{$self->file_names};
  my $total_filesizes=ceil($self->total_filesize);
  my $directory = $self->directory;
  my $file_names = join("\n", @{$self->file_names});

	my $body = <<BODY;
The files below should not be stored on $directory .
Please review them and clean them up where nessisary. If files are included erroneously, please contact path-help\@sanger.ac.uk .

Total Number of files for deletion: $total_files
Total space taken up by those files (GB): $total_filesizes

$file_names

BODY
	sendmail(-from => $self->email_from_address,
	           -to => 'ap13@sanger.ac.uk',
	      -subject => "Files for possible deletion in $directory",
	         -body => $body);

}

# ToDo put into module
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
