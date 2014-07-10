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

use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
use Test::FailWarnings;
use Test::Deep '!blessed';
use Test::Fatal;
binmode( Test::More->builder->$_, ":utf8" )
  for qw/output failure_output todo_output/;

my $CLASS = "Monocrat::Cluster::SingleServer";

require_ok($CLASS);

subtest "empty config" => sub {
    my $obj =
      new_ok( $CLASS, [ config => { mongod => [ {} ] } ], "new with empty config" );

    diag explain [ $obj->all_servers ];
};

done_testing;
# vim: ts=4 sts=4 sw=4 et:
