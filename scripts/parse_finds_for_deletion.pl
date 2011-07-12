use strict;
use warnings;

#open();
my %users_files ;
while(<>)
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
  $users_files{$file_details[0]}{filesizes} += $file_details[2];
  
}

sub total_file_sizes
{
  my $total_size = 0;
  my %users_files = shift;
  for my $user( keys %users_files)
  {
    $total_size += $users_files{$user}{filesizes};
  }
}


for my $user( keys %users_files)
{
 print "\t".$users_files{$user}{filesizes}."\n";
}
