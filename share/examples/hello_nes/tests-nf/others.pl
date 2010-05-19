#!/usr/bin/perl

  use Nes::Framework;
  
  use strict;
  use warnings;   
  
  my $view = Nes::Framework::View->new( 'others' );
  my $vars = {};

  $vars->{'number'} = '1';
  
  $vars->{'spanish_numbers'} = {
    One   => 'Uno',
    Two   => 'Dos',
    Three => 'Tres',
    Four  => 'Cuatro',
    Five  => 'Cinco',
  };
  
  $vars->{'users'} = [ 
    { 
      name   => 'One',
      email  => 'one@example.com',
    },
    { 
      name   => 'Two',
      email  => 'two@example.com',
    },
    { 
      name   => 'Three',
      email  => 'three@example.com',
    }                                    
  ];

  warn "* test error in others *";
  
  $view->fill($vars);

1;
