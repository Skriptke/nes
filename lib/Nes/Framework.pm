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

  package Nes::Framework;
  
  use Nes::View;
  
  use strict;
  use warnings;  
  
  our $VERSION = '0.00_1';   
  
  my $NesFramework;
  
  sub new {
    my $class = shift;
    my $self  = bless {}, $class;
    $self->{'name'}   = shift;
    $self->{'params'} = shift || {};
    $self->set;


    # debug info
    if ( my $Top = Nes::View->get_Top ) {
      my $Con = Nes::View->get_Container;
      
      $NesFramework->{$Top->{'container'}} = [] 
        if !$NesFramework->{$Top->{'container'}};
        
      push(@{$NesFramework->{$Con}}, 
        { "$class->new( $self->{'name'} )" => $self });
        
      $Con->{'debug_info'}{'Nes::Framework'} 
        = $NesFramework->{$Con};
    }

    return $self;
  }
  
  sub set {
    my $self   = shift;
    my $params = shift || {};
    $self->{'params'}  = { %{$self->{'params'}}, %$params };
    $self->{'value'}   = $self->{'params'}{$self->{'name'}} || $self->{'value'} || '';
    $self->{'_set'}    = '';
    $self->{'_set'}  ||= $self->{'params'}{'_any'} if $self->{'value'};
    $self->{'_set'}  ||= $self->{'params'}{'_value'}{$self->{'value'}};
    $self->{'_set'}  ||= $self->{'params'}{'_empty'};
 
    
    return $self;
  }    
  
  sub go2 {
    my $self = shift;

    $self->go;

    return $self;
  }
 
  sub go {
    my $self = shift;
    $self->{'vars'} ||= {};

    $self->_go( $self->{'params'}{'_always'}, $self->{'vars'} ) 
      if $self->{'params'}{'_always'};

    $self->_go( $self->{'_set'}, $self->{'vars'} ) 
      if $self->{'_set'};

    return $self->{'vars'};
  }
  
  sub _go {
    my $self = shift;
    my $set  = shift;

    if ( ref ( $set ) eq 'HASH' ) {
      $self->{'vars'} = { %{$self->{'vars'}}, %{$set} };
    } elsif ( ref ( $set ) eq 'ARRAY' ) {
      return $self;
    } else {
      my $callback = $set;
      my $rvars = &$callback($self->{'vars'}) || {}; 
      $self->{'vars'} = { %{$self->{'vars'}}, %{$rvars} };
    }
    
    return $self;
  }    
  
  package Nes::Framework::Model;
  use vars qw(@ISA);
  @ISA = qw( Nes::Framework );   
  
  sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( shift );

    $self->set(@_);

    return $self;
  }
  
  sub set {
    my $self   = shift;
    $self->SUPER::set( shift );

    $self->{'DAL'}    = $self->{'params'}{'DAL'};
    $self->{'native'} = $self->{'DAL'}->{'native'};
    
    return $self;
  } 
   
  sub connect {
    my $self = shift;
    
    return if $self->{'is_connect'};

    my $return = $self->{'DAL'}->connect( @_ );
    $self->{'is_connect'} = $return ? 0 : 1;
    
    return $return;
  }

  sub disconnect {
    my $self = shift;

    return if !$self->{'is_connect'};
    $self->{'is_connect'} = 0;
    
    return wantarray ? 
      ($self->{'DAL'}->disconnect( @_ )) 
      :
      $self->{'DAL'}->disconnect( @_ ); 
  }

  sub select {
    my $self  = shift;
    my ($param,@params) = @_;

    $self->connect;

    if ( ref( $param ) eq 'HASH' ) {
      my ($vars) = @params || {};
      foreach my $this ( keys %$param ) {
        $vars->{$this} = $self->{'DAL'}->select( @{$param->{$this}} );
      }
      return $vars;
    } else {
      @params = @_;
    }
   
    return wantarray ? 
      ($self->{'DAL'}->select( @params )) 
      :
      $self->{'DAL'}->select( @params ); 
  }
  
  sub insert {
    my $self = shift;
    
    return wantarray ? 
      ($self->{'DAL'}->insert( @_ )) 
      :
      $self->{'DAL'}->insert( @_ ); 
  }
  
  sub update {
    my $self = shift;
    
    return wantarray ? 
      ($self->{'DAL'}->update( @_ )) 
      :
      $self->{'DAL'}->update( @_ ); 
  }
  
  sub delete {
    my $self = shift;
    
    return wantarray ? 
      ($self->{'DAL'}->delete( @_ )) 
      :
      $self->{'DAL'}->delete( @_ ); 
  }
  
  sub sql {
    my $self = shift;
    
    return wantarray ? 
      ($self->{'DAL'}->sql( @_ )) 
      :
      $self->{'DAL'}->sql( @_ ); 
  }  
  
  package Nes::Framework::View;
  use vars qw(@ISA);
  @ISA = qw( Nes::Framework );   

  sub new {
    my $class = shift;
    my $name  = shift || 'no_name';
    my $self  = $class->SUPER::new( $name, shift );

    (
      $self->{'view'},
      $self->{'container'},
      $self->{'query'},
      $self->{'CFG'},
      $self->{'session'},
      $self->{'cookies'}
    ) = Nes::View->new( $self->{'params'} );
    
    $self->{'parent'}= $self->{'container'}->{'parent'};

    return wantarray ? 
      ($self,$self->{'query'},$self->{'CFG'},$self->{'session'},$self->{'cookies'}) : 
      $self;
  }
  
  sub instance {
    my $self  = shift;

    return wantarray ? 
      ($self,$self->{'query'},$self->{'CFG'},$self->{'session'},$self->{'cookies'}) : 
      $self;
  }  
  
  sub parent_vars {
    my $self  = shift;

    return $self->{'parent'}->{'content_obj'}->{'tags'};
  }  
  
  sub get_var {
    my $self  = shift;
    my $obj   = shift;
    my $param = shift;

    return $self->{$obj}{$param};
  }
  
  sub get_cfg {
    my $self  = shift;
    my $param = shift;

    return $self->{'CFG'}{$param};
  }
  
  sub get_env {
    my $self  = shift;
    my $param = shift;

    return $self->{'view'}->{'nes'}->get_nes_env($param);
  }   
  
  sub fill {
    my $self = shift;
    my @controllers = @_;
    my %tags = ();
    
    foreach my $this ( @controllers ) {
      if ( ref ( $this ) eq 'HASH' ) {
        %tags = ( %tags, %$this );
      } else {
        my $vars = $this->go();
        %tags = ( %tags, %$vars );
      }
    }
    
    $self->{'view'}->fill(\%tags);
    
    return;
  }

  sub add {
    my $self = shift;
    my @controllers = @_;
    my %tags;
    
    foreach my $this ( @controllers ) {
      if ( ref ( $this ) eq 'HASH' ) {
        %tags = ( %tags, %$this );
      } else {
        my $vars = $this->go();
        %tags = ( %tags, %$vars );
      }
    }
    
    $self->{'view'}->add(%tags);
    
    return;
  }
  
  package Nes::Framework::Container;
  use vars qw(@ISA);
  @ISA = qw( Nes::Framework );   

  sub new {
    my $class = shift;
    my $name  = shift || 'no_name';
    my $self  = $class->SUPER::new( $name, shift  );
 
    $self->{'container'} = Nes::ViewContainer->new( $self->{'params'} );

    return $self;
  }
  
  sub fill {
    my $self = shift;
    my @controllers = @_;
    my %tags = ();
    
    foreach my $this ( @controllers ) {
      if ( ref ( $this ) eq 'HASH' ) {
        %tags = ( %tags, %$this );
      } else {
        my $vars = $this->go();
        %tags = ( %tags, %$vars );
      }
    }
    
    $self->{'container'}->set( $self->{'params'} );

    return $self->{'container'}->fill(\%tags);
  }
    
  package Nes::Framework::Controller;
  use vars qw(@ISA);
  @ISA = qw( Nes::Framework );   

  sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( shift );
    
    (
      $self->{'view'},
      $self->{'container'},
      $self->{'query'},
      $self->{'CFG'},
      $self->{'session'},
      $self->{'cookies'}
    ) = Nes::View->new( $self->{'params'} );
    
    $self->{'parent'} = $self->{'container'}->{'parent'};
    $self->{'q'}      = $self->{'query'}->{'q'};
    $self->{'CGI'}    = $self->{'query'}->{'CGI'};
    
    $self->{'obj_params'}      = $self->{'container'}->{'obj_params'};
    $self->{'obj_params_hash'} = $self->{'container'}->{'obj_params_hash'};    

    return $self;
  }
   
  package Nes::Framework::Controller::Request;
  use vars qw(@ISA);
  @ISA = qw( Nes::Framework::Controller );   
  
  sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( shift );
    $self->{'value'} = $self->{'q'}{$self->{'name'}};
    $self->set;
                     
    return $self;
  }
  
  sub go {
    my $self = shift;
    $self->SUPER::go;

    if ( ref ( $self->{'_set'} ) eq 'ARRAY' ) {
      foreach my $key ( @{$self->{'_set'}} ) {
        next if !$key;
        if (ref ( $key ) eq 'HASH') {
          my ($hkey, $hvalue) = each(%$key);
          next if !$hkey;
          $self->{'vars'}{$hkey} = $self->{'CGI'}->param($hvalue);
        } else {        
          $self->{'vars'}{$key} = $self->{'CGI'}->param($key);
        }
      }   
    }
 
    return $self->{'vars'};
  }      
  
  package Nes::Framework::Controller::Cookie;
  use vars qw(@ISA);
  @ISA = qw( Nes::Framework::Controller );   
  
  sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( shift );
    $self->load;

    return $self;
  }
  
  sub del {
    my $self = shift;
    my ( $path, $domain ) = @_;
    
    if ( ref( $path ) eq 'HASH' ) {
      $self->{'cookies'}->del( $self->{'name'} );
    } else {
      $self->{'cookies'}->del( $self->{'name'}, $path, $domain );
    }
    
    return;
  }
  
  sub create {
    my $self = shift;
    my ( $param, $expire, $path, $domain ) = @_;
    $self->{'params'}{'separator'} ||= ':-:';

    if ( ref( $param ) eq 'HASH' ) {
      my $value = '';
      foreach my $key ( keys %{$param} ){
        $value .= $self->{'params'}{'separator'} if $value;
        $value .= $key.'=>';
        $value .= $param->{$key} || '';
      }
      $self->{'cookies'}->create( 
        $self->{'name'}, 
        $value, 
        $param->{'expire'}, 
        $param->{'path'}, 
        $param->{'domain'} 
      );
    } else {
      $self->{'cookies'}->create( $self->{'name'}, $param, $expire, $path, $domain );
    }

    return;
  }
  
  sub load {
    my $self = shift;
    $self->{'params'}{'separator'} ||= ':-:';

    my $cookie = $self->{'cookies'}->get($self->{'name'});
    if ( $cookie ) {
      foreach my $var ( split($self->{'params'}{'separator'},$cookie) ) {
        my ( $key, $value ) = split('=>',$var,2);
        $self->{'vars'}->{$key} = $value;
      }
    }

  }

  package Nes::Framework::Controller::Vars;
  use vars qw(@ISA);
  @ISA = qw( Nes::Framework::Controller );   

  sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( shift );

    return $self;
  }
  
  sub go {
    my $self = shift;

    if ( ref( $self->{'value'} ) eq 'HASH' ) {
      my $values = $self->{'value'};
      foreach my $value ( keys %{$values} ) {
        next if !$values->{$value};
        $self->{'params'}{$self->{'name'}} = $value; 
        $self->set;
        $self->SUPER::go;
      }
      $self->SUPER::go if !$self->{'vars'};
    } else {
      $self->SUPER::go;
    }

    return $self->{'vars'};
  }

1;

__END__

  .----------------.
  | Nes::Framework |
  '--.-------------'
     |   .-----------------------.
     |---+ Nes::Framework::Model |
     |   '-----------------------'
     |   .---------------------.
     |---+ Nes::Framework::DAL |
     |   '--.------------------'
     |      |   .---------------------------.
     |      |---+ Nes::Framework::DAL::NSQL |
     |      |   '---------------------------'
     |      |   .--------------------------.
     |      |---+ Nes::Framework::DAL::DBI |
     |      |   '--------------------------'
     |      |   .---------------------------.
     |      '---+ Nes::Framework::DAL::DBIx |
     |          '---------------------------'     
     |   .----------------------------.
     |---+ Nes::Framework::Controller |
     |   '--.-------------------------'
     |      |   .-------------------------------------.
     |      |---+ Nes::Framework::Controller::Request |
     |      |   '-------------------------------------'
     |      |   .-------------------------------------.
     |      |---+ Nes::Framework::Controller::Cookies |
     |      |   '-------------------------------------'
     |      |   .----------------------------------.
     |      '---+ Nes::Framework::Controller::Vars |
     |          '----------------------------------'
     |   .----------------------.
     |---+ Nes::Framework::View |
     |   '----------------------'
     |   .---------------------------.
     '---+ Nes::Framework::Container |
         '---------------------------'   





  
  