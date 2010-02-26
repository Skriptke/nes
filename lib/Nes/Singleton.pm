#!/usr/bin/perl

# -----------------------------------------------------------------------------
#
#  Nes by Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón
#  Licensed under the GNU GPL.
#
#  Sample:
#  http://nes.sourceforge.net/
#
#  Repository:
#  http://github.com/Skriptke/nes
# 
#  Version 1.00_03
#
#  Singleton.pm
#
# -----------------------------------------------------------------------------

{
  package Nes::Singleton;
  
  my $singleton;

  sub new {
    my $class = shift;
    my $self  = $singleton || bless {}, $class;
    my ( $file ) = @_;

    utl::cleanup(\$singleton) if $ENV{'MOD_PERL'};   

    if ( $singleton ) {
      $self->{'container'} = nes_container->get_obj();
      $self->{'this_template_name'} = $self->{'container'}->{'file_name'};
      $self->{'top_template_name'}  = $self->{'top_container'}->{'file'};      
      return $self;
    } else {
      $singleton = $self;
    }

    $self->{'file'} = $ENV{'PATH_TRANSLATED'} || $file;
   
    my $dir = $self->{'file'};
    $dir =~ s/[^\/]*$//;
    chdir $dir;
    use Cwd;
    $dir = getcwd;
  
    die "No template defined: $@" if !$self->{'file'};

    $self->{'CFG'}           = Nes::Setting->new();
    $self->{'top_container'} = nes_top_container->new( $self->{'file'}, $dir );
    $self->{'container'}     = nes_container->get_obj();
    $self->{'cookies'}       = nes_cookie->get_obj();
    $self->{'session'}       = nes_session->get_obj();
    $self->{'query'}         = nes_query->get_obj();      
    $self->{'nes'}           = $self->{'top_container'}->{'nes'};
    $self->{'this_template_name'} = $self->{'container'}->{'file_name'};
    $self->{'top_template_name'}  = $self->{'top_container'}->{'file'};

    # todo, comprobar que existe el juego de caracteres antes
    use POSIX qw(locale_h);
    POSIX::setlocale(LC_ALL, "$self->{'CFG'}{'locale'}") if $self->{'CFG'}{'locale'};
    
    if ( $file ) {
      # todo, implementar emulación CGI para linea de comandos
#      $ENV{REMOTE_ADDR} = '127.0.0.1' if !$ENV{REMOTE_ADDR};
      $self->run();
      exit;
    }
   
    return $self;
  }

  sub run {
    my $self = shift;

    $self->{'container'}->go(); 
    $self->{'top_container'}->{'container'}->out();
    $self->{'container'}->forget();
    $self->{'top_container'}->forget();

    return;
  }

  sub out {
    my $self = shift;
    my %tags;
    (%tags) = @_;

    $self->{'container'}->set_tags(%tags);
    $self->{'container'}->interpret(); 

    return;
  }

}


1;