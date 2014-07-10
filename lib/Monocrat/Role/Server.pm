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

package Monocrat::Role::Server;
# ABSTRACT: Common role for modeling a single MongoDB server
# VERSION

use Moo::Role;

use CPAN::Meta::Requirements;
use MongoDB;
use Path::Tiny;
use Types::Path::Tiny qw/Path/;
use Types::Standard -types;
use Version::Next qw/next_version/;
use version;

use namespace::clean;

#--------------------------------------------------------------------------#
# To be satisfied by consumer
#--------------------------------------------------------------------------#

# XXX do we need these? or do these functions wind up in some other
# backend-specific class
##requires 'is_alive';
##requires 'start';
##requires 'stop';

requires '_build_command_name';
requires '_build_command_args';
requires '_logger';

has command_name => (
    is  => 'lazy',
    isa => Str,
);

has command_args => (
    is  => 'lazy',
    isa => Str,
);

#--------------------------------------------------------------------------#
# Attributes
#--------------------------------------------------------------------------#

# Required

has config => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

# Defaults

has hostname => (
    is      => 'ro',
    isa     => Str,
    default => 'localhost',
);

has port => (
    is      => 'rwp',
    isa     => Num,
    default => 27017,
    clearer => 1,
);

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

has did_auth_setup => (
    is  => 'rwp',
    isa => Bool,
);

# Lazy

has name => (
    is  => 'lazy',
    isa => Str,
);

sub _build_name {
    my ($self) = @_;
    return $self->config->{name}
      if defined $self->config->{name};
    my ($name) = $self->hostname =~ m{ ^ (?:[^@]+\@)? ([^.]+) }x;
    return $name;
}

has data_dir => (
    is     => 'lazy',
    isa    => Path,
    coerce => Path->coercion,
);

sub _build_data_dir {
    my ($self) = @_;
    return path( $self->config->{data_dir} // 'mongodb' );
}

has logpath => (
    is     => 'lazy',
    isa    => Path,
    coerce => Path->coercion,
);

sub _build_logpath {
    my ($self) = @_;
    return $self->data_dir->child('logs');
}

has pidfilepath => (
    is     => 'lazy',
    isa    => Path,
    coerce => Path->coercion,
);

sub _build_pidfilepath {
    my ($self) = @_;
    return $self->data_dir->child('pids');
}

# Private

has _server_version => (
    is  => 'rw',
    isa => InstanceOf ['version'],
);

has _version_wanted => (
    is  => 'lazy',
    isa => Str,
);

sub _build__version_wanted {
    my ($self) = @_;
    return $self->config->{version} // $self->defaults->{version} // 0;
}

has _version_constraint => (
    is  => 'lazy',
    isa => InstanceOf ['CPAN::Meta::Requirements'],
);

sub _build__version_constraint {
    my ($self) = @_;
    # abusing CMR for this
    my $cmr    = CPAN::Meta::Requirements->new;
    my $target = $self->version_wanted;
    if ( $target =~ /^v?\d+\.\d+\.\d+$/ ) {
        $target =~ s/^v?(.*)/v$1/;
        $cmr->exact_version( mongo => $target );
    }
    elsif ( $target =~ /^v?\d+\.\d+$/ ) {
        $target =~ s/^v?(.*)/v$1/;
        $cmr->add_minimum( mongo => $target );
        $cmr->add_string_requirement( mongo => "< " . next_version($target) );
    }
    else {
        # hope it's a valid version range specifier
        $cmr->add_string_requirement( mongo => $target );
    }
    return $cmr;
}

#--------------------------------------------------------------------------#
# Methods
#--------------------------------------------------------------------------#

sub as_host_port {
    my ($self) = @_;
    return $self->hostname . ":" . $self->port;
}

sub as_uri {
    my ($self) = @_;
    return "mongodb://" . $self->as_host_port;
}

sub _merged_command_args {
    my ($self) = @_;
    my @args;
    for my $line ( $self->defaults->{args}, $self->config->{args} ) {
        push @args, split ' ', $line if defined $line;
    }
    push @args, split ' ', $self->command_args;
    push @args, '--port', $self->port, '--logpath', $self->logpath,
      '--pidfilepath' => $self->pidfilepath;
##    if ( $self->did_auth_setup ) {
##        push @args, '--auth';
##    }

    return @args;
}

##sub add_user {
##    my ( $self, $user, $password, $roles ) = @_;
##    $self->_logger->debug("Adding root user");
##    my $doc = Tie::IxHash->new(
##        pwd   => $password,
##        roles => $roles,
##    );
##    if ( $self->server_version >= v2.6.0 ) {
##        $doc->Unshift( createUser => $user );
##        $self->client->get_database("admin")->_try_run_command($doc);
##    }
##    else {
##        $doc->Unshift( user => $user );
##        $self->client->get_database("admin")->get_collection("system.users")->save($doc);
##    }
##    return;
##}

1;
