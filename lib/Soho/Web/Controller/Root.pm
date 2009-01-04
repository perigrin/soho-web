package Soho::Web::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Soho::Web::Controller::Root - Root Controller for Soho::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ( $self, $c, $name ) = @_;
    $name ||= $c->config->{default_node};
    my %node = $c->model('Wiki')->retrieve_node($name);

    $node{raw_content} = $node{content};
    $node{content}     = $c->model('Wiki')->format( $node{content} );
    $node{name}        = $name;

    # Wiki::Toolkit wraps all metadata in arrayrefs even if the data is just one
    # element. unwrap it here.
    $node{'last.user'}   = $node{metadata}{user}[0];

    $c->stash->{template} = 'node.tt2';
    $c->stash->{node}     = \%node;
}

sub access_denied : Private {
    my ( $self, $c, $action ) = @_;
    $c->response->redirect('/login');
}

sub edit : Path('/edit') ActionClass('REST') {
}

sub edit_GET {
    my ( $self, $c, $name ) = @_;
    $name ||= $c->config->{default_node};
    my %node = $c->model('Wiki')->retrieve_node($name);
    $node{name} = $name;

    if ( $c->stash->{preview_content} ) {
        $node{content}         = $c->stash->{preview_content};
        $node{preview_content} = $c->model('Wiki')->format( $node{content} );
    }
    $c->stash->{template} = 'edit.tt2';
    $c->stash->{node}     = \%node;
}

sub edit_POST {
    my ( $self, $c, $name ) = @_;
    $name ||= $c->config->{default_node};
    my $content = $c->request->param("node.content");
    my $cksum   = $c->request->param("node.checksum");

    if ( $c->request->param('save') ) {
        $self->save_page( $c, $name, $content, $cksum );
    }
    elsif ( $c->request->param('preview') ) {
        $c->flash->{preview_content} = $content;
        $c->response->redirect("/edit/$name");
    }
    else { $c->response->redirect("/$name"); }
}

sub save_page {
    my ( $self, $c, $name, $content, $cksum ) = @_;
    my $url = $c->user->url;
    # NOTE: even though the user is specified as a raw scalar here, it's
    # silently wrapped in an arrayref by Wiki::Toolkit, so be sure to unwrap
    # appropriately when viewing.
    my $written =
      eval { $c->model('Wiki')->write_node( $name, $content, $cksum, { user => $c->user->url} ) };
    if ($written) {
        $c->response->redirect("/$name");
    }
    else {
        warn "write failed for $name: $written $! $@";
        $c->response->redirect("/$name");
    }
}

sub login : Path('/login') {
    my ( $self, $c ) = @_;
    if ( $c->authenticate() ) {
        $c->res->redirect( $c->uri_for('/') );
    }
    else {
        $c->stash->{template} = 'login.tt2';
    }
}

sub logout : Path('/logout') ActionClass('REST') {
}

sub logout_GET {
    my ( $self, $c ) = @_;
    $c->logout;
    $c->response->redirect('/');
}

sub history : Path('/node:history') {
    my ($self, $c, $name) = @_;
    $name ||= $c->config->{default_node};
    my @versions = $c->model('Wiki')->list_node_all_versions(
        name => $name,
        with_content => 0,
        with_metadata => 1,
    );

    my $revisions = [ map { 
        {
            date => $_->{last_modified},
            user => $_->{metadata}{user} } 
        }
        @versions ];
    $c->stash->{template}    = 'history.tt2';
    $c->stash->{revisions}   = $revisions;
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {
}

=head1 AUTHOR

Chris Prather

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
