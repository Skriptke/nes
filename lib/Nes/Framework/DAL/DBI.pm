# -----------------------------------------------------------------------------
#
#  Nes by Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón Barbero
#  Licensed under the GNU GPL.
#
#  CPAN:
#  http://search.cpan.org/dist/Nes/
#
#  Sample:
#  http://nes.sourceforge.net/
#
#  Repository:
#  http://github.com/Skriptke/nes
#
#  Nes::Framework HMVC (Hierarchical-Model-View-Controller) View Oriented.
#
# -----------------------------------------------------------------------------

  package Nes::Framework::DAL::DBI;
  use base 'Nes::Framework::DAL'; 
  
  our $VERSION = '0.00_1';  
  use strict;
  use warnings; 
  use Nes::View;
  use SQL::Abstract;
  use DBI;  

  sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( shift );

    $self->{'sql'} = SQL::Abstract->new;
    $self->{'dbh'} = undef;
    $self->set(@_);
    
    $self->{'native'} = $self->{'dbh'};
    
    return $self;
  }
  
 
  sub connect {
    my $self = shift;

    return if $self->{'dbh'};

    eval {
      $self->{'error'}  = '';
      $self->{'dbh'} = DBI->connect($self->{'data_source'},$self->{'user'},$self->{'pass'});
      $self->{'error'}  = $DBI::errstr;
    };    
    
    return $self->{'error'}; 
  }

  sub disconnect {
    my $self = shift;

    return if !$self->{'dbh'};

    eval {
      $self->{'error'}  = '';
      $self->{'dbh'}->disconnect;
      $self->{'error'} = $DBI::errstr;
    };
    
    $self->{'dbh'} = undef if !$self->{'error'};
    
    return $self->{'error'}; 
  }
  
  sub sql {
    my $self = shift;
    my $sql  = shift;
    
    if ( $sql =~ /^SELECT/i ) { 
      return wantarray ? 
        ($self->select( $sql )) 
        :
        $self->select( $sql ); 
    }
  } 

  sub select {
    my $self = shift;
    my ($first, $fields, $where, $order) = @_;
    
    my $stmt = '';
    my @bind = ();
    if ( $fields || $where || $order ) {
      ($stmt, @bind) = $self->{'sql'}->select($first, $fields, $where, $order);
    } else {
      $stmt = $first;
    }
  
    my $sth = '';
    eval {
      $self->{'error'}  = '';
      $sth = $self->{'dbh'}->prepare( $stmt );
      $self->{'filas'} = $sth->execute( @bind );
      $self->{'error'} = $DBI::errstr;
    };   
    return $self->{'error'} if $DBI::errstr;

    my $response;
    while( my $this = $sth->fetchrow_hashref ) {
      push(@{$response}, $this);
    }
    $sth->finish(); 
    
    return wantarray ? @{$response} : $response;
  }
  
 
 
1;




  
  