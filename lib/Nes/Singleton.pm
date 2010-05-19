#  *******************************************************
#  *******************************************************
#  *****                                             *****
#  ****   Nes::Singleton is obsolete, use Nes::View   ****
#  ****   is maintained for backward compatibility.   ****
#  *****                                             *****
#  *******************************************************
#  *******************************************************

  package Nes::Singleton;
  
  use strict;
  use warnings;  
  no  warnings "redefine";
  use Nes::View;
  
  my $instance = undef;

  sub new {
    my $class  = shift;
    my $self   = $instance || bless {}, $class;
    $instance ||= $self;
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
    
    $self->{'view'} = Nes::View->new( $self->{'params'} );
    
    $self->{'top_container'} = $self->{'view'}{'top_container'};
    $self->{'container'}     = $self->{'view'}{'container'};
    $self->{'CFG'}           = $self->{'view'}{'CFG'};
    $self->{'cookies'}       = $self->{'view'}{'cookies'};
    $self->{'session'}       = $self->{'view'}{'session'};
    $self->{'query'}         = $self->{'view'}{'query'};
    $self->{'register'}      = $self->{'view'}{'register'};
    $self->{'nes'}           = $self->{'view'}{'nes'};  
    
    $self->{'this_template_name'} = $self->{'container'}->{'file_name'};
    $self->{'top_template_name'}  = $self->{'top_container'}->{'file'};
      
    return $self;
  }

  sub run {
    my $self = shift;

    $self->{'view'}->run;

    return;
  }

  # Compatibility by older version
  sub out {
    my $self = shift;
    my %tags;
    (%tags) = @_;

    $self->{'container'}->set_tags(%tags);
    $self->{'container'}->interpret(); 

    return;
  }
  
  # Compatibility by older version
  sub add {
    my $self = shift;
    my %tags;
    (%tags) = @_;

    $self->{'container'}->add_tags(%tags);

    return;
  }  
   
  sub start {
    my $class = shift;

    return Nes::View->new_by_dispatch;
  }
 
  sub instance {
    my $class = shift;

    utl::cleanup(\$instance) if $ENV{'MOD_PERL'};
    ($class)->new if !$instance;
          
    return $instance;
  }

  sub init_by_cgi {
    my $self = shift;
    
    $self->{'view'}->init_by_cgi;

    return;
  }  
  
  sub init {
    my $self = shift;
    
    $self->{'view'}->init;

    return $self->{'container'};
  }


1;