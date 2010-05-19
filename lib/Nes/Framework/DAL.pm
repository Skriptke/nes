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

  package Nes::Framework::DAL;
  use base 'Nes::Framework';
  
  our $VERSION = '0.00_1';   
  use strict;
  use warnings;
  use Nes::View;
  
  sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( shift );

    $self->{'CFG'} = Nes::View::get_Top->{'CFG'};
    $self->{'dbh'} = undef;
    $self->set(@_);
    
    $self->{'native'} = undef;
    
    return $self;
  }
  
  sub set {
    my $self   = shift;
    $self->SUPER::set( shift );    

    $self->{'base'} = $self->{'params'}{'DB_base'}   || $self->{'CFG'}{'DB_base'}   || '';
    $self->{'user'} = $self->{'params'}{'DB_user'}   || $self->{'CFG'}{'DB_user'}   || '';
    $self->{'pass'} = $self->{'params'}{'DB_pass'}   || $self->{'CFG'}{'DB_pass'}   || '';
    $self->{'drv'}  = $self->{'params'}{'DB_driver'} || $self->{'CFG'}{'DB_driver'} || '';
    $self->{'host'} = $self->{'params'}{'DB_host'}   || $self->{'CFG'}{'DB_host'}   || '';
    $self->{'port'} = $self->{'params'}{'DB_port'}   || $self->{'CFG'}{'DB_port'}   || '';
    
    $self->{'data_source'} = 
      "DBI:$self->{'drv'}:database=$self->{'base'};host=$self->{'host'};port=$self->{'port'}";
 
    
    return $self;
  }
  

 
 
1;




  
  