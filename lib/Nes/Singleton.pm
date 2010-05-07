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
#  Singleton.pm
#
# -----------------------------------------------------------------------------

  package Nes::Singleton;
  
  use strict;
  use warnings;  
  
  my $instance;

  sub new {
    my $class  = shift;
    my $self   = $instance || bless {}, $class;
    my $params = shift;

    $self->{'params'} = ();
    if ( ref( $params ) eq 'HASH' ) {
      $self->{'params'} = $params;
    } else {
      (
      $self->{'params'}{'template'},
      $self->{'params'}{'nes_top_dir'},
      $self->{'params'}{'nes_dir'},
      $self->{'params'}{'no_init'},
      $self->{'params'}{'no_exit'}
      ) = $params;
    }

    if ( $instance ) {
      $self->{'container'} = nes_container->get_obj();
      $self->{'this_template_name'} = $self->{'container'}->{'file_name'};
      $self->{'top_template_name'}  = $self->{'top_container'}->{'file'};      
      return $self;
    } else {
      
      # Compatibility by older version and call by .cgi or command line
      $self->{'already_init'}    = 0;
      $self->{'already_running'} = 0;
      # ---------------------------------------------------------------    
      
      $instance = $self;
    }
    
    if ( $self->{'params'}{'template'} ) {
      # the template is in parameter, call by .cgi or command line
      $self->init_by_cgi();
    } else {
      # the template is in $ENV{'PATH_TRANSLATED'}, call by dispatch.cgi
      $self->init();
    }
      
    return $self;
  }

  sub run {
    my $self = shift;

    # Compatibility by older version and call by .cgi or command line
    return if $self->{'already_running'};
    $self->{'already_running'} = 1;
    # ----------------------------------------------------------------

    $self->{'container'}->go(); 
    $self->{'top_container'}->{'container'}->out();
    $self->{'container'}->forget();

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
  
  sub add {
    my $self = shift;
    my %tags;
    (%tags) = @_;

    $self->{'container'}->add_tags(%tags);

    return;
  }
   
  sub start {
    my $class = shift;
    
    utl::cleanup(\$instance) if $ENV{'MOD_PERL'};

    return $class->new();
  }
 
  sub instance {
    my $class = shift;
    
    return $instance;
  }

  sub init_by_cgi {
    my $self = shift;
    
    return        if $self->{'params'}{'no_init'};
    $self->init() if !$self->{'already_init'};
    $self->run()  if !$self->{'already_running'};
    
    # mod_perl muestra un error cuando se usa exit
    CORE::exit(0)  if !$self->{'params'}{'no_exit'};

    return;
  }  
  
  sub init {
    my $self = shift;
    
    $self->{'file'} = $ENV{'PATH_TRANSLATED'} || $self->{'params'}{'template'};
    die "No template defined: $@" if !$self->{'file'};

    my $dir = $self->{'file'};
    $dir =~ s/[^\/]*$//;
    chdir $dir;
    use Cwd;
    $dir = getcwd;
  
    $self->{'CFG'}           = Nes::Setting->new( 
                                   $self->{'params'}{'nes_top_dir'}, 
                                   $self->{'params'}{'nes_dir'}  
                               );
    $self->{'top_container'} = nes_top_container->new( $self->{'file'}, $dir );
    $self->{'container'}     = nes_container->get_obj();
    $self->{'cookies'}       = nes_cookie->get_obj();
    $self->{'session'}       = nes_session->get_obj();
    $self->{'query'}         = nes_query->get_obj();
    $self->{'register'}      = nes_register->get_obj();
    $self->{'nes'}           = $self->{'top_container'}->{'nes'};
    $self->{'this_template_name'} = $self->{'container'}->{'file_name'};
    $self->{'top_template_name'}  = $self->{'top_container'}->{'file'};
    
    # todo, comprobar que existe el juego de caracteres antes
    use POSIX qw(locale_h);
    POSIX::setlocale(LC_ALL, "$self->{'CFG'}{'locale'}") if $self->{'CFG'}{'locale'};
    
    $self->{'already_init'} = 1; 

    return $self->{'container'};
  }


1;