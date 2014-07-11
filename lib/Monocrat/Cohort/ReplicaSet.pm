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

package Monocrat::Cohort::ReplicaSet;
# ABSTRACT: Model a MongoDB replica set cohort
# VERSION

use Moo;

use JSON;
use MongoDB;
use Try::Tiny::Retry qw/:all/;
use Types::Standard -types;

use namespace::clean;

with 'MooseX::Role::Logger', 'Monocrat::Role::Cohort';

has set_name => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

around 'munge_server_config' => sub {
    my $orig = shift;
    my $self = shift;
    my $copy = $orig->( $self, @_ );
    $copy->{args} = join( " ", ( $copy->{args} // () ), "--replSet", $self->set_name );
    return $copy;
};

sub rs_initiate {
    my ($self)  = @_;
    my ($first) = $self->all_servers;

    # XXX eventually may have to figure out adding additional parameters
    my $members = [
        map {
            ;
            {
                host => $_->as_host_port,
                %{ $_->config->{rs_config} // {} }
            }
          }
          sort { $a->name cmp $b->name } $self->all_servers
    ];

    for my $i ( 0 .. $#$members ) {
        $members->[$i]{_id} = $i;
    }

    my $rs_config = {
        _id     => $self->set_name,
        members => $members,
    };

    $self->_logger->debug( "configuring replica set with: " . to_json($rs_config) );

    # not $self->client because this needs to be a direct connection
    my $client = MongoDB::MongoClient->new( host => $first->as_uri, dt_type => undef );
    $client->get_database("admin")
      ->_try_run_command( { replSetInitiate => $rs_config } );

    $self->_logger->debug("waiting for primary");

    $self->wait_for_all_hosts;

    return;
}

sub wait_for_all_hosts {
    my ($self)  = @_;
    my ($first) = $self->all_servers;
    retry {
        my $client = MongoDB::MongoClient->new( host => $first->as_uri, dt_type => undef );
        my $admin = $client->get_database("admin");
        if ( my $status = eval { $admin->_try_run_command( { replSetGetStatus => 1 } ) } ) {
            my @member_states = map { $_->{state} } @{ $status->{members} };
            $self->_logger->debug("host states: @member_states");
            die "Hosts not all PRIMARY or SECONDARY or ARBITER\n"
              unless @member_states == grep { $_ == 1 || $_ == 2 || $_ == 7 } @member_states;
        }
        else {
            die "Can't get replica set status";
        }
    }
    delay {
        return if $_[0] >= 180;
        sleep 1;
    }
    catch { chomp; die "$_. Giving up!" };

    return;
}

sub stepdown_primary {
    my ( $self, $timeout_secs ) = @_;
    # eval because command causes primary to close connection, causing network error
    eval {
        $self->client->get_database("admin")->_try_run_command( { replSetStepDown => 5 } );
    };
    return;
}

1;
