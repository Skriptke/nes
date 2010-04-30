# -----------------------------------------------------------------------------
#
#  Nes by Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón Barbero
#  Licensed under the GNU GPL.
#
#  Sample use CGI::Application::Plugin::Nes 
#
# -----------------------------------------------------------------------------

package TestNes;

use strict;
use warnings;

use base 'CGI::Application::Plugin::Nes';

# compatibility with CGI.pm (slightly slower)
# $ENV{CGI_APP_NES_BY_CGI} = 1;

# require if exec by .cgi
# $ENV{CGI_APP_NES_DIR} = '/full/path/to/cgi-bin/nes';

sub setup {
    my $self = shift;

    $self->start_mode('start');
    $self->mode_param('action');

    $self->run_modes(
        'start'    => 'default',
        'Modules'  => 'modules',
        'Inludes'  => 'includes',
        'Objects'  => 'objects',
        'Sql'      => 'sql',
        'others'   => 'others'
    );

}

sub default {
    my $self = shift;

    my $nes = Nes::Singleton->new();
    my %nes_tags;
    
    $nes_tags{'action'} = 'def.nhtml';

    $nes->out(%nes_tags);
}

sub modules {
    my $self = shift;

    my $nes = Nes::Singleton->new();
    my %nes_tags;
    
    $nes_tags{'action'} = 'modules.nhtml';

    $nes->out(%nes_tags);
}

sub includes {
    my $self = shift;

    my $nes = Nes::Singleton->new();
    my %nes_tags;
    
    $nes_tags{'action'} = 'includes.nhtml';

    $nes->out(%nes_tags);
}

sub objects {
    my $self = shift;

    my $nes = Nes::Singleton->new();
    my %nes_tags;
    
    $nes_tags{'action'} = 'objects.nhtml';

    $nes->out(%nes_tags);
}

sub sql {
    my $self = shift;

    my $nes = Nes::Singleton->new();
    my %nes_tags;
    
    $nes_tags{'action'} = 'sql.nhtml';

    $nes->out(%nes_tags);
}

sub others {
    my $self = shift;

    use Nes;
    my $nes = Nes::Singleton->new;
    my %nes_tags;
    
    $nes_tags{'action'}  = 'others.nhtml';
  
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
}

return 1;
 
