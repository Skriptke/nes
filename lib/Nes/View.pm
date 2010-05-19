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
# -----------------------------------------------------------------------------

  package Nes::View;
  
  use strict;
  use warnings;
  no  warnings "redefine";
  use Nes;

  our $VERSION = '0.01';
  
  my $Top = undef;
    
  sub new {
    my $class  = shift;
    my $params = shift || {};
   
    if ( !$Top ) {
      $Top = Nes::ViewTop->new( $params );
      
      # Call by .cgi or command line, else the template is in $ENV{'PATH_TRANSLATED'}
      if ( $params->{'template'} ) {
        # emulate /cgi-bin/nes/dispach.cgi
        $Top->init_by_cgi();
      } else {
        $Top->init;
      }
      
    }

    return Nes::ViewChild->new( $Top );    
  }
  
  sub new_by_dispatch {
    my $class = shift;
 
    # mod_perl
    $Top = undef;
   
    return $class->new;
  }
  
  sub new_by_template {
    my $class = shift;
    my $params = shift || {};
 
    if ( !$Top ) {
      $Top = Nes::ViewTop->new( $params );
      $Top->init;
    }

    return Nes::ViewChild->new( $Top );  
  }  
  
  sub get_Top {
    my $class = shift;

    return $Top;
  }
  
  sub get_Container {
    my $class = shift;

    return $Top->{'top'}->get_self_container if $Top;
  }   

  package Nes::ViewTop;
  use vars qw(@ISA);

  sub new {
    my $class = shift;
    my $self  = bless {}, $class;
    $self->{'params'} = shift || {};

    return $self;
  }
    
  sub run {
    my $self = shift;

    $self->{'container'}->go(); 
    $self->{'container'}->out();
    $self->{'container'}->forget();

    return;
  }
  
  sub fill {
    my $self = shift;
    my $tags = shift;

    $self->{'container'}->set_tags(%$tags);
    $self->{'container'}->interpret(); 

    return;
  }
  
  sub fill_vars {
    my $self = shift;
    my $tags = shift;

    $self->{'container'}->set_tags(%$tags);

    return;
  }

  sub init_by_cgi {
    my $self = shift;

    # emulate /cgi-bin/nes/dispach.cgi
    
    $self->init();
    $self->run();

    # mod_perl muestra un error cuando se usa exit
    CORE::exit(0) if !$self->{'params'}{'no_exit'};
    
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
  
    $self->{'CFG'}       = Nes::Setting->new( 
      $self->{'params'}{'nes_top_dir'}, 
      $self->{'params'}{'nes_dir'}  
    );
    $self->{'top'}       = nes_top_container->new( $self->{'file'}, $dir );
    $self->{'container'} = $self->{'top'}->get_self_container;
    $self->{'cookies'}   = nes_cookie->get_obj();
    $self->{'session'}   = nes_session->get_obj();
    $self->{'query'}     = nes_query->get_obj();
    $self->{'register'}  = nes_register->get_obj();
    $self->{'nes'}       = $self->{'top'}->{'nes'}; 
    
    $self->{'this_template_name'} = $self->{'container'}->{'file_name'};
    $self->{'top_template_name'}  = $self->{'top'}->{'file'}; 
    
    # todo, comprobar que existe el juego de caracteres antes
    use POSIX qw(locale_h);
    POSIX::setlocale(LC_ALL, "$self->{'CFG'}{'locale'}") if $self->{'CFG'}{'locale'};
       
    return;
  }  

  package Nes::ViewChild;
  use vars qw(@ISA);
  @ISA = qw( Nes::ViewTop );  

  sub new {
    my $class = shift;
    my $self  = bless {}, $class;
    my $Top   = shift;

    $self->{'top_container'}      = $Top->{'top'};
    $self->{'CFG'}                = $Top->{'CFG'};
    $self->{'container'}          = $Top->{'top'}->get_self_container;
    $self->{'cookies'}            = $Top->{'cookies'};
    $self->{'session'}            = $Top->{'session'};
    $self->{'query'}              = $Top->{'query'};
    $self->{'register'}           = $Top->{'register'};
    $self->{'nes'}                = $Top->{'nes'};
    $self->{'top_template_name'}  = $Top->{'top'}->{'file'}; 
    $self->{'this_template_name'} = $self->{'container'}->{'file_name'};
    $self->{'obj_params'}         = $self->{'container'}->{'obj_params'};
    $self->{'obj_params_hash'}    = $self->{'obj_params'};
    foreach my $param ( @{$self->{'obj_params_hash'}} ) {
      next if $param !~ /\=\>/;
      $param = eval "{ $param }";
    }

    return wantarray ? 
      (
        $self,
        $self->{'container'},
        $self->{'query'},
        $self->{'CFG'},
        $self->{'session'},
        $self->{'cookies'}
      ) 
      : $self;
  }   

  package Nes::ViewContainer;
 
  sub new {
    my $class = shift;
    my $self  = bless {}, $class;
    $self->{'params'} = shift || {};

    $self->{'out'} = '';
    
    return $self;
  }
  
  sub set {
    my $self   = shift;
    my $params = shift || {};
    $self->{'params'} = { %{$self->{'params'}}, %$params };
    
    return $self;
  }  

  sub fill {
    my $self = shift;
    my $tags = shift;

    if ( $self->{'params'}{'template'} ) {
      my $container = nes_container->new( $self->{'params'}{'template'} );
      $container->set_obj_params( $self->{'params'}{'template'}, $self->{'params'}{'obj_params'} );
      $container->set_tags(%$tags);
      $container->go();
      $self->{'out'} .= $container->get_out();
      $container->del_obj_params( $self->{'params'}{'template'}, $self->{'params'}{'obj_params'} );
      $container->forget();
    }
    
    if ( $self->{'params'}{'source'} ) {
      my $interpret = nes_interpret->new( $self->{'params'}{'source'} );
      $self->{'out'} .= $interpret->go(%$tags); 
    }

    return $self->{'out'};
  }
  
1;

__END__

  .-----------------------------------. .-----------------------------------.
  |     GET or POST HTTP Request      | |   Command line: ./template.cgi    |
  | http://example.com/template.nhtml | |  http://example.com/template.cgi  |
  '-----------------------------------' '-----------------------------------'
                    |                                    |
                    v                                    v
  .-----------------------------------. .-----------------------------------.
  |     /cgi-bin/nes/dispatch.cgi     | |        emulate dispatch.cgi       |
  '-----------------------------------' '-----------------------------------'
                    |                                    |      
                    '------------------.-----------------'      
                                       |
                                       v
                   .-------------------------------------------.
                   |   Create Top Container and environment.   |
                   |-------------------------------------------|
                   | new {'CFG'} for this dir                  |
                   | new {'top_container '} for template.nhtml |
                   | new {'register'}                          |
                   | new {'query'}                             |
                   | new {'cookies'}                           |
                   | new {'session'}                           |
                   | new {'container'} for template.nhtml      |
                   '-------------------------------------------'             
                                       |
                                       v
                   .-------------------------------------------.
                   |      Run Container of this template       | <---.
                   |-------------------------------------------|     |
                   | get {: NES 1.0 ... :} line                |     |
                   | new {'content_obj'} for this content type |     |
                   '-------------------------------------------'     |          
                                       |                             |
                                       v                             |
                   .-------------------------------------------.     |
                   | do Perl scripts in line {: NES 1.0 ... :} |     |
                   |               and plugins                 |     |
                   '-------------------------------------------'     |
                                       |                             |
                                       v                             |
                   .-------------------------------------------.     |
                   |         Interpret and fill vars.          |     |
                   '-------------------------------------------'     |
                                       |                             |
                                       v                       ( interaction )
                            .---------------------.                  |
                            | {: include ... :} ? |---[ yes ]--------'
                            '---------------------'                         
                                       |
                                     [ no ]
                                       |
                                       v
                      _____________________________________
                     |  ________________________________   |
                     | |                                |  |
                     | |                                |  |
                     | |       print HTTP Headers       |  |
                     | |                                |  |
                     | |         print the out          |  |
                     | |                                |O |
                     | |                                |O |
                     | |________________________________|  |
                     |_____________________________________|
                     |\                                     \
                     \ \ [][][][][][][][][][][][][]   [][][] \
                      \ \  [][][][][][][][][][][][][]  [][][] \
                       \ \  [][][][__________][][][][]  [][][] \
                        \ \_____________________________________\
                         \_______________________________________|
