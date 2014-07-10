#  Copyright 2014 MongoDB, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

use 5.010;
use strict;
use warnings;

package Monocrat::Role::Cohort;
# ABSTRACT: Common role for modeling a group of similar MongoDB servers
# VERSION

use Moo::Role;

use Module::Runtime qw/require_module/;
use Types::Standard -types;

use namespace::clean;

# To be satisfied by consumer

requires '_logger';

# Required

has server_config_list => (
    is       => 'ro',
    isa      => ArrayRef [HashRef],
    required => 1,
);

# Default

has defaults => (
    is      => 'ro',
    isa     => HashRef,
    default => sub { {} },
);

has auth_config => (
    is      => 'ro',
    isa     => HashRef,
    default => sub { {} },
);

has server_type => (
    is      => 'ro',
    isa     => Enum [qw/mongod mongos mongoc/],
    default => 'mongod',
);

# Private

has _servers => (
    is  => 'lazy',
    isa => HashRef [ ConsumerOf ['Monocrat::Role::Server'] ],
);

my %SERVER_MAP = (
    mongod => "Monocrat::Server::Mongod",
##    mongos => "Monocrat::Server::Mongos",
##    mongoc => "Monocrat::Server::Mongoc",
);

sub _build__servers {
    my ($self) = @_;
    my $set = {};
    for my $server ( @{ $self->server_config_list } ) {
        $server = $self->munge_server_config($server);
        my $class = $SERVER_MAP{ $self->server_type };
        require_module($class);
        $set->{ $server->{name} } = $class->new(
            config      => $server,
            defaults    => $self->defaults,
            auth_config => $self->auth_config,
        );
    }
    return $set;
}

# Methods

sub all_servers {
    my ($self) = @_;
    return sort { $a->name cmp $b->name } values %{ $self->_servers };
}

sub get_server {
    my ( $self, $name ) = @_;
    for my $server ( $self->all_servers ) {
        return $server if $name eq $server->name;
    }
    return;
}

sub as_uri {
    my ($self) = @_;
    my $uri = "mongodb://" . $self->as_pairs;
    if ( $self->auth_config ) {
        my ( $u, $p ) = @{ $self->auth_config }{qw/user password/};
        $uri =~ s{mongodb://}{mongodb://$u:$p\@};
    }
    return $uri;
}

sub as_pairs {
    my ($self) = @_;
    return join( ",", map { $_->hostname . ":" . $_->port } $self->all_servers );
}

sub munge_server_config {
    my ( $self, $config ) = @_;
    state $counter = 0;
    my $copy = {%$config};
    $copy->{name} //= 'host' . $counter++;
    return $copy;
}

1;
