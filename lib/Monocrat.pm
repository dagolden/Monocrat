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

package Monocrat;
# ABSTRACT: MongoDB cluster deployment tool
# VERSION

use Carp;
use YAML::XS;

use Moo;
use Module::Runtime qw/require_module/;
use Types::Standard -types;
use Types::Path::Tiny qw/AbsFile/;
use namespace::clean;

my %CLUSTER_MAP = (
    single  => "Monocrat::Cluster::Single",
    replica => "Monocrat::Cluster::ReplicaSet",
);

# Optional

has config_file => (
    is      => 'ro',
    isa     => Str,
    default => '',
);

# Lazy or default

has config => (
    is  => 'lazy',
    isa => HashRef,
);

sub _build_config {
    my ($self) = @_;
    my $config_file = $self->config_file;
    Carp::croak( sprintf( "no readable config file '%s' found", $self->config_file ) )
      unless -r $self->config_file;
    my ($config) = YAML::XS::LoadFile( $self->config_file );
    return $config;
}

has cluster_type => (
    is  => 'lazy',
    isa => Enum [qw/single replica sharded/],
);

sub _build_cluster_type {
    my ($self) = @_;
    return $self->config->{type};
}

has cluster => (
    is      => 'lazy',
    isa     => ConsumerOf ['Monocrat::Role::Cluster'],
    handles => [qw/as_uri get_server/],
);

sub _build_cluster {
    my ($self) = @_;
    my $class = $CLUSTER_MAP{ $self->type };
    require_module($class);
    return $class->new( config => $self->config, );
}

1;

=for Pod::Coverage BUILD

=head1 SYNOPSIS

    use Monocrat;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

=for :list
* Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
