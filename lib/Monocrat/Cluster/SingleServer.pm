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

package Monocrat::Cluster::SingleServer;
# ABSTRACT: Model a MongoDB single-server cluster
# VERSION

use Moo;

use Carp qw/croak/;
use Monocrat::Cohort::PeerSet;
use Types::Standard -types;

use namespace::clean;

has cohort => (
    is      => 'lazy',
    isa     => InstanceOf ['Monocrat::Cohort::PeerSet'],
    handles => [qw/as_uri as_pairs get_server all_servers/]
);

sub _build_cohort {
    my ($self) = @_;

    return Monocrat::Cohort::PeerSet->new(
        defaults           => $self->defaults,
        auth_config        => $self->auth_config,
        server_config_list => $self->_server_config_list,
    );
}

has _server_config_list => (
    is  => 'lazy',
    isa => ArrayRef,
);

sub _build__server_config_list {
    my ($self) = @_;
    return $self->config->{mongod} // [];
}

sub BUILD {
    my ($self) = @_;
    if ( @{ $self->_server_config_list } != 1 ) {
        croak "Error: "
          . __PACKAGE__
          . " requires a single server in the 'mongod' config array";
    }
}

with 'Monocrat::Role::Cluster';

1;
