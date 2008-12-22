package Soho::Wiki;
use Moose;
use Wiki::Toolkit;
use Moose::Util::TypeConstraints;

use Wiki::Toolkit::Store::SQLite;
use Wiki::Toolkit::Setup::SQLite;

class_type 'Wiki::Toolkit::Store::Database';
coerce 'Wiki::Toolkit::Store::Database' => from Str => via {
    Wiki::Toolkit::Setup::SQLite::setup($_);
    Wiki::Toolkit::Store::SQLite->new( dbname => $_ );
};

has store => (
    isa        => 'Wiki::Toolkit::Store::Database',
    is         => 'ro',
    coerce     => 1,
    lazy_build => 1,
);

sub _build_store {
    my $dbname = "/tmp/store.db";
    Wiki::Toolkit::Setup::SQLite::setup($dbname);
    Wiki::Toolkit::Store::SQLite->new( dbname => $dbname );
}

use Wiki::Toolkit::Search::Plucene;

class_type 'Wiki::Toolkit::Search::Base';
coerce 'Wiki::Toolkit::Search::Base' => from Str => via {
    Wiki::Toolkit::Search::Plucene->new( path => $_, ),;
};

has search => (
    isa        => 'Wiki::Toolkit::Search::Base',
    is         => 'ro',
    coerce     => 1,
    lazy_build => 1,
);

sub _build_search {
    Wiki::Toolkit::Search::Plucene->new( path => '/tmp/kinosearch', );
}

use Wiki::Toolkit::Formatter::MultiMarkdown;

has formatter => (
    isa        => 'Object',
    is         => 'ro',
    lazy_build => 1,
);

sub _build_formatter {
    Wiki::Toolkit::Formatter::MultiMarkdown->new(),;
}

has wiki => (
    isa        => 'Wiki::Toolkit',
    is         => 'ro',
    lazy_build => 1,
    handles    => [
        qw(
          retrieve_node
          format
          write_node
          )
    ]
);

sub _build_wiki {
    Wiki::Toolkit->new(
        store     => $_[0]->store,
        search    => $_[0]->search,
        formatter => $_[0]->formatter,
    );
}

no Moose;
1;
