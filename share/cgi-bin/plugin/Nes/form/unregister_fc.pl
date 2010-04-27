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
#  Version 1.03
#
#  register_captcha.pl
#
# -----------------------------------------------------------------------------

use strict;
use Nes;
use forms_plugin;

my $nes = Nes::Singleton->new();

Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc',                '' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_obfuscated',     '' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_check',          '' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_field_attempts', '' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_captcha',        '' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_captcha_html',   '' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_captcha_code',   '' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_handler',        '' );

# don't use this tags in you template
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', '_fc_begin',         '' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', '_fc_end',           '' );


# don't forget to return a true value from the file
1;

