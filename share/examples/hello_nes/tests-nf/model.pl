#!/usr/bin/perl

  use Nes::Framework;
  use MyDAL;
    
  use strict;
  use warnings;   

  my $defaults = {
    zones  => [],
    count  => [],
    option => 'none',
  }; 

  my $view  = Nes::Framework::View->new( 'test model' );
  my $radio = Nes::Framework::Controller::Request->new( 'radio' );
  my $city  = Nes::Framework::Controller::Request->new( 'city' );
  my $model = Nes::Framework::Model->new( 'model', { DAL => MyDAL->new( 'dal' ) } );
  my $opti  = Nes::Framework::Controller->new( 'option' );
  my $vars  = $defaults;
  $vars->{'city'} = $city->{'value'} || '';

  $radio->set({
    _always => {
      count => [ 'timezones', 'count(*) AS timezoneid' ],      
    },
    _value  => {    
      gtm    => { 
        zones => [
          'timezones',
          'timezoneid,gmt',
          { timezoneid => $city->{'value'} },
        ],
      }, 
      offset => { 
        zones => [ 
          "SELECT timezoneid,offset 
           FROM timezones 
           WHERE timezoneid = '$city->{'value'}'" 
        ],
      },
      both   => {
        zones => [
          'timezones',
          '*',
          { timezoneid => $city->{'value'} },
        ],
      },
    }
  }); 
  
  $opti->set({
    option  => $radio->{'value'},
    _value  => {    
      gtm    => { option => 'GMT' }, 
      offset => { option => 'Offset' }, 
      both   => { option => 'Both' }, 
    }    
  }) if $city->{'value'};   

  $model->set({
    model => $city->{'value'},
    _any  => sub { $model->select( $radio->go ); },
  });  

  $view->fill($vars,$opti,$model);


1;

