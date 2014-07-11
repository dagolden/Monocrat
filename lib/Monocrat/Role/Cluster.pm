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

package Monocrat::Role::Cluster;
# ABSTRACT: Common role for modeling a MongoDB cluster
# VERSION

use Moo::Role;
use Types::Standard -types;
use namespace::clean;

requires 'as_uri';
requires 'as_pairs';
requires 'get_server';
requires 'all_servers';

has config => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has defaults => (
    is  => 'lazy',
    isa => HashRef,
);

sub _build_defaults {
    my ($self) = @_;
    return $self->config->{defaults} // {};
}

has auth_config => (
    is  => 'lazy',
    isa => HashRef,
);

sub _build_auth_config {
    my ($self) = @_;
    return $self->config->{auth} // {};
}

1;
