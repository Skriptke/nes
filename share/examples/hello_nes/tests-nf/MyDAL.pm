
  package MyDAL;

  use Nes::Framework::DAL::DBI;
  
  use strict;
  use warnings;   
  
  sub new {
    my $class = shift;

    return Nes::Framework::DAL::DBI->new( @_ );
  }
 
1;
