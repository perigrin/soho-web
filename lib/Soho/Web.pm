package Soho::Web;

use Moose;
use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw{
  -Debug
  ConfigLoader
  Static::Simple

  Authentication

  Authorization::ACL

  Session
  Session::Store::FastMmap
  Session::State::Cookie

};

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in soho_web.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name          => 'Soho-Web',
    default_node  => 'home',
    'Model::Wiki' => { args => { store => 'root/main.db', }, },
    session        => { flash_to_stash => 1 },
    authentication => {
        default_realm => 'openid',
        realms        => {
            openid => {
                ua_class => "LWPx::ParanoidAgent",
                ua_args =>
                  { whitelisted_hosts => [qw/ 127.0.0.1 localhost /], },
                credential => {
                    class => "OpenID",
                    store => { class => "OpenID", },
                },
            },

        },
    },
);
# Start the application
__PACKAGE__->setup;

__PACKAGE__->deny_access_unless( "/edit", sub { $_[0]->user });


=head1 NAME

Soho::Web - Catalyst based application

=head1 SYNOPSIS

    script/soho_web_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Soho::Web::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Chris Prather

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
