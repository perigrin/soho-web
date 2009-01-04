package Soho::Web::Controller::Blog;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Soho::Web::Controller::Blog - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub blog : Path('/blog') {

}

sub post : Path('/blog/post') ActionClass('REST') {
}

sub post_GET {
    my ( $self, $c ) = @_;
    my $name = $c->stash->{'node.name'} || $c->config->{default_node};
    my %node = $c->model('Wiki')->retrieve_node($name);
    $node{name} = $name;

    if ( $c->stash->{preview_content} ) {
        $node{content}         = $c->stash->{preview_content};
        $node{preview_content} = $c->model('Wiki')->format( $node{content} );
    }
    $c->stash->{template} = 'blog/post.tt2';
    $c->stash->{node}     = \%node;
}

sub post_POST {
    my ( $self, $c ) = @_;

    my $name    = $c->request->param("node.name");
    my $content = $c->request->param("node.content");
    my $cksum   = $c->request->param("node.checksum");

    if ( $c->request->param('save') ) {
        $self->save_page( $c, $name, $content, $cksum );
    }
    elsif ( $c->request->param('preview') ) {
        $c->flash->{preview_content} = $content;
        $c->flash->{'node.name'} = $name;
        $c->response->redirect('/blog/post');
    }
    else { $c->response->redirect("/$name"); }
}

=head1 AUTHOR

Chris Prather

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
