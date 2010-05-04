#!/usr/bin/perl

# -----------------------------------------------------------------------------
#
#  Copyright 2010 Luis Romero del Campo.
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
#  ajax.pl
#
# -----------------------------------------------------------------------------

  use strict;
  use Nes;
  
  my $nes   = Nes::Singleton->new();
  my $obj   = $nes->{'query'}->{'q'}{'obj_param_0'};
  my $data  = '('.$nes->{'query'}->{'q'}{$obj.'_param_1'}.')';
  my %vars  = eval "$data";

  $vars{'params'}     ||= '';
  $vars{'script'}     ||= '';
  $vars{'script_tpl'} ||= ''; 
  
  foreach my $param ( keys %{ $vars{'lparam'} } ) {
    $vars{'params'} .= $param.'='.$vars{'lparam'}{$param}.'&';
  }
  
  foreach my $param ( keys %{ $vars{'vparam'} } ) {
    $vars{'params'} .= $param.'="+'.$vars{'vparam'}{$param}.'+"&';
  }

  warn "$obj object requires at least one event.\n" if !$vars{'events'};
  
  my $i = 0;
  foreach my $event ( @{ $vars{'events'} } ) {
    
    warn "$obj object, to set an 'events' without parameter event: $event->{'idname'}\n" if !$event->{'event'};
    warn "$obj object, to set an 'events' without parameter idname: $event->{'event'}\n" if !$event->{'idname'};
    warn "$obj object requires URL in 'open' parameter in event: $event->{'event'} $event->{'idname'}\n" if !$event->{'event'};
    $event->{'event'}   = lc($event->{'event'});

    if ( $event->{'synchro'} ) {
      $event->{'synchro'} = 'false';
    } else {
      $event->{'synchro'} = 'true';
    }
    
    $event->{'set_headers'} = '';
    $event->{'set_content_type'} = 0;
    foreach my $key ( keys %{$event} ) {
      next if $key !~ /^header_/;
      my $header = $key;
      $header =~ s/^header_(.*)/$1/;
      $event->{'set_content_type'} = 1 if $header =~ /Content-Type/i;
      $event->{'set_headers'} .= $event->{'idname'}.'_'.$event->{'event'}.'_cx.setRequestHeader("'.$header.'","'.$event->{$key}.'"); ';
    }
    
    if ( !$event->{'set_content_type'} ) {
      $event->{'set_headers'} .= $event->{'idname'}.'_'.$event->{'event'}.'_cx.setRequestHeader("Content-Type","application/x-www-form-urlencoded");';
    } 

    foreach my $param ( keys %{ $event->{'lparam'} } ) {
      $event->{'params'} .= $param.'='.$event->{'lparam'}{$param}.'&';
    }
    foreach my $param ( keys %{ $event->{'vparam'} } ) {
      $event->{'params'} .= $param.'="+'.$event->{'vparam'}{$param}.'+"&';
    }

  }

  $nes->out(%vars);

1;

