use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Soho::Web' }
BEGIN { use_ok 'Soho::Web::Controller::Blog' }

ok( request('/blog')->is_success, 'Request should succeed' );


