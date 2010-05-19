#!/usr/bin/perl

  use Nes::Framework;
  
  use strict;
  use warnings;   
  
  my $view = Nes::Framework::View->new( 'Session' );
  my $form = Nes::Framework::Controller::Request->new( 'login' );
  
  # when a variable takes any/true value.
  my $sess = Nes::Framework::Controller::Vars->new( 'session' );
  
  my $defaults = {
    user   => '',
    pass   => '',
    expire => '5m',
  };

  $form->set({
    _value  => {
      # if submit, automatic fill vars in array from form
      Submit => [ { user => 'field_user' }, { pass => 'field_pass' }, { del => 'field_del' } ],
    },
    _always => $defaults,
  });
  

  $sess->set({
    
    # get vars from $form
    session => $form->go,
    _always => $form->{'vars'},
    
    _value  => {
      # if $vars->{'user'} has a value
      user => \&create_session,
      
      # if $vars->{'del'} has a value
      del  => \&delete_session,
    }
    
  });  

  $view->fill($sess);
  
  sub create_session {
    my $vars = shift;

    return if $vars->{'del'};
    if ( test_login( $vars->{'user'}, $vars->{'pass'} ) ) {
      $view->{'session'}->create( $vars->{'user'}, $vars->{'expire'} );
    }

    return $vars;
  }
  
  sub delete_session {
    my $vars = shift;

    $view->{'session'}->del();
 
    return $vars;
  } 
  
  sub test_login {
    my $user  = shift;
    my $pass  = shift;
    
    return 0 if !$user || !$pass;
    return $user if $pass eq '1234';
    return 0;
  }  
  



1;

