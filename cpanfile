requires "CPAN::Meta::Requirements" => "0";
requires "Carp" => "0";
requires "DDP" => "0";
requires "JSON" => "0";
requires "Module::Runtime" => "0";
requires "MongoDB" => "0";
requires "Moo" => "0";
requires "Moo::Role" => "0";
requires "MooX::Cmd" => "0";
requires "MooX::Options" => "0";
requires "MooseX::Role::Logger" => "0";
requires "Path::Tiny" => "0";
requires "Try::Tiny" => "0";
requires "Try::Tiny::Retry" => "0";
requires "Types::Path::Tiny" => "0";
requires "Types::Standard" => "0";
requires "Version::Next" => "0";
requires "YAML::XS" => "0";
requires "namespace::clean" => "0";
requires "perl" => "5.010";
requires "strict" => "0";
requires "version" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec::Functions" => "0";
  requires "List::Util" => "0";
  requires "Test::Deep" => "0";
  requires "Test::FailWarnings" => "0";
  requires "Test::Fatal" => "0";
  requires "Test::More" => "0.96";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "0";
  recommends "CPAN::Meta::Requirements" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.17";
};

on 'develop' => sub {
  requires "Dist::Zilla" => "5";
  requires "Dist::Zilla::PluginBundle::DAGOLDEN" => "0.061";
  requires "File::Spec" => "0";
  requires "File::Temp" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CPAN::Meta" => "0";
  requires "Test::More" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
  requires "Test::Spelling" => "0.12";
};
