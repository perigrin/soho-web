package Soho::Web::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
    {
        CATALYST_VAR => 'c',
        INCLUDE_PATH => [
            Soho::Web->path_to( 'root', 'src' ),
            Soho::Web->path_to( 'root', 'lib' )
        ],
        ERROR => 'error.tt2',
        TIMER => 0
    }
);

1;
