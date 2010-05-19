#!/usr/bin/perl
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
#  index.pl
#
# -----------------------------------------------------------------------------

  use Nes::Framework;
  
  use strict;
  use warnings;   
  
  my $view   = Nes::Framework::View->new( 'index' );
  my $action = Nes::Framework::Controller::Request->new( 'action' );
  
  # GET or POST ...&action=...&...
  $action->set({
    
    # # name = value, default in Request: $action->{'q'}{'action'}
    # action => $action->{'q'}{'action'},
    
    # action=[value] if value no is in this set or action no set
    _empty  => { title => 'Test Nes::Framework' },
    
    _value  => {
      # if action=Modules
      Modules    => { 
        content  => 'modules.nhtml', 
        title    => 'Test Nes::Framework Modules',
      },
      # if action=Includes
      Includes   => { 
        content  => 'includes.nhtml', 
        title    => 'Test Nes::Framework Includes',
      },
      # ...
      Objects    => { 
        content  => 'objects.nhtml', 
        title    => 'Test Nes::Framework Objects',
      },
      Sql        => { 
        content  => 'sql.nhtml', 
        title    => 'Test Nes::Framework Sql',
      },
      others    => { 
        content  => 'others.nhtml', 
        title    => 'Test Nes::Framework Others',
      },    
      Request    => { 
        content  => 'request.nhtml', 
        title    => 'Nes::Framework::Controller::Request',
      },
      Cookies    => { 
        content  => 'cookies.nhtml', 
        title    => 'Nes::Framework::Controller::Cookies',
      },
      Vars    => { 
        content  => 'vars.nhtml', 
        title    => 'Nes::Framework::Controller::Vars',
      },
      Model    => { 
        content  => 'model.nhtml', 
        title    => 'Nes::Framework::Model & Nes::Framework::DAL',
      },
      View    => { 
        content  => 'view.nhtml', 
        title    => 'Nes::Framework::View & Nes::Framework::Container',
      },
    }
  }); 
  
 
  $view->fill($action);
 
1;
