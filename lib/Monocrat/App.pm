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

package Monocrat::App;
# ABSTRACT: MongoDB cluster deployment command line app
# VERSION

use Moo;

use MooX::Cmd;
use MooX::Options;
use Types::Path::Tiny qw/AbsPath/;
use Types::Standard -types;

option 'config_file' => (
    is      => 'ro',
    isa     => AbsPath,
    coerce  => AbsPath->coercion,
    default => 'monocrat.yml',
    format  => 's',
    doc     => 'YAML file for the cluster (default monocrat.yml)',
);

sub execute {
    my ( $self, $args ) = @_;
    say "Usage: $0 <command> [options...]";
}

sub BUILD {
    my ($self) = @_;
    die sprintf( "Couldn't find config file '%s'\n", $self->config_file )
      unless -r $self->config_file;
}

package Monocrat::App::Cmd::Dump;

use Moo;
use MooX::Cmd;

sub execute {
    my ($self) = @_;
    say "in Dump";

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
