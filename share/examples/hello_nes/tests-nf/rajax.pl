#!/usr/bin/perl

  use Nes::Framework;
  use MyDAL;
    
  use strict;
  use warnings;   
  
  select(undef, undef, undef, 0.5);
 
  my $defaults = {
    options  => [],
  };  
 
  my $view   = Nes::Framework::View->new( 'ajax' );
  my $zoneid = Nes::Framework::Controller::Request->new( 'zone' );
  my $model  = Nes::Framework::Model->new( 'ids', { DAL => MyDAL->new( 'dal' ) } );
  
  $zoneid->set({
    _any  => {
      options => [
        'timezones', 
        'timezoneid', 
        { timezoneid => 
          { 'LIKE', $zoneid->{'value'}.'%' } 
        }
      ]
    }   
  });  

  $model->set({
    ids => $zoneid->{'value'},
    _any  => sub { $model->select( $zoneid->go ); }
  });
  

  $view->fill($defaults,$model);

1;
