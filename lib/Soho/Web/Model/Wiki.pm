package Soho::Web::Model::Wiki;
use Moose;
BEGIN { extends qw(Catalyst::Model::Adaptor) }

__PACKAGE__->config(
    class       => 'Soho::Wiki',
    constructor => 'new',
    args        => {
        store  => 'root/wiki.db',
        search => 'root/kinosearch',
    }
);

no Moose;
1;
__END__
