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
#  others.pl
#
# -----------------------------------------------------------------------------

  use Nes;
  my $nes = Nes::Singleton->new;
  my %nes_tags;
  
  $nes_tags{'number'} = '1';

  $nes_tags{'spanish_numbers'} = {
    One   => 'Uno',
    Two   => 'Dos',
    Three => 'Tres',
    Four  => 'Cuatro',
    Five  => 'Cinco',
    };
  
  $nes_tags{'users'} = [ 
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
  
  $nes->out(%nes_tags);

1;
