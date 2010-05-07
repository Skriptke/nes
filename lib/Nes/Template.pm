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
#  Version 1.04
#
#  Template.pm
#
# -----------------------------------------------------------------------------

  package Nes::Template;
  
  use strict;
  use warnings;
  use Nes;  
  
  sub new {
    my $class = shift;
    my $self  = bless {}, $class;

    return $self;
  }
  
  sub run {
    my $self = shift;
    my ($tags, $out) = @_;

    $self->{'container'}->set_out_content( $out ) if $out;
    $self->{'container'}->set_tags(%$tags);
    $self->{'container'}->go();

    return;
  }

  sub out {
    my $self = shift;

    $self->{'container'}->out();
    $self->{'container'}->forget();

    return;
  }
  
  sub get_out_ref {
    my $self = shift;

    return \$self->{'obj'}->{'out'};
  }
   
  sub get_out {
    my $self = shift;

    return $self->{'container'}->get_out_content();
  }  
  
  sub set_out {
    my $self = shift;
    my $out  = shift;

    $self->{'container'}->set_out_content( $out );
    
    return;
  }

{
  package Nes::Template::Top;
  use vars qw(@ISA);
  @ISA = qw( Nes::Template );  
  
  sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->{'params'} = shift;

    $self->{'container'} = '';
    $self->{'obj'} = '';
    $self->{'nes'} = '';
    $self->init if $self->{'params'}{'template'};

    return $self;
  }
  
  sub init {
    my $self = shift;
    $self->{'params'} = shift if @_;
    $self->{'params'}{'no_init'} = 1; 

    $self->{'nes'} = Nes::Singleton->new( $self->{'params'} );
    $self->{'nes'}->init();
    
    $self->{'container'} = $self->{'nes'}->{'top_container'}->{'container'};
    $self->{'obj'} = $self->{'container'}->{'content_obj'};
    
    my $scripts = "@{$self->{'container'}->{'file_script'}}";
    die "Nes::Template not support script ($scripts) in top template, use 'none' " 
      if $scripts ne 'none' && $scripts ne '';
    
    return;
  }  
  
  sub by_CGI {
    my $self = shift;
    
    $self->{'nes'}->{'query'}->by_CGI;
    
  }  

}

{ 
  package Nes::Template::Container;
  use vars qw(@ISA);
  @ISA = qw( Nes::Template );  

  sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->{'params'} = shift;

    $self->{'container'} = '';
    $self->{'obj'} = '';
    $self->init if $self->{'params'}{'template'};
   
    return $self;
  }   
  
  sub init {
    my $self = shift;
    $self->{'params'} = shift if @_;
    $self->{'params'}{'no_init'} = 1;  

    warn "Requires create a Nes::Template::Top first" if !Nes::Singleton->instance();

    $self->{'container'} = nes_container->new( $self->{'params'}{'template'} );
    $self->{'obj'} = $self->{'container'}->{'content_obj'};
    
    return;
  }
  
}

1;