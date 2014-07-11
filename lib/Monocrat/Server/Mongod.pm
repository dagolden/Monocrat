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

package Monocrat::Server::Mongod;
# ABSTRACT: Model a single MongoDB database server
# VERSION

use Moo;
use Types::Path::Tiny qw/AbsDir/;
use namespace::clean;

with 'MooseX::Role::Logger', 'Monocrat::Role::Server';

sub _build_command_name { return 'mongod' }

sub _build_command_args {
    my ($self) = @_;
    return "--dbpath " . $self->data_dir;
}

1;
