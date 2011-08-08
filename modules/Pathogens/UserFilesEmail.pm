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
  Hi,

  In an attempt to manage the disk usage on pathogen disks we are now running regular checks of the filesystems. Attached is a list of files owned by you that could potentially be deleted or converted to a more efficient data storage format. These files are either

  sam files : all sam files should be converted to bam files
  fastq files : it should not be necessary to keep a copy of the fastq files as they are available through pathfind
  files ending with ~ : these are temporary files and should be deleted

  Can you please take a careful look at the list of files attached and either delete or convert them to a more efficient format. This is a matter of urgency and we would greatly appreciate if you could look at this list asap. If you need help with cleaning up these files or if you require additional disk space to work in please email path-help\@sanger.ac.uk

  Thanks,

  Pathogen Software Developers  

$file_names

BODY
	sendmail(-from => $self->email_from_address,
	           -to => $self->email_to_address,
	      -subject => "Files needing attention on $directory",
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
