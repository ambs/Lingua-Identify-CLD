use 5.008;
use strict;
use warnings;

use lib 'inc';

use MyBuilder;

my $builder = MyBuilder->new
  (
   module_name         => 'Lingua::Identify::CLD',
   license             => 'bsd',
   dist_author         => q{Alberto Simões <ambs@cpan.org>},
   dist_version_from   => 'lib/Lingua/Identify/CLD.pm',
   build_requires      => {
                           'Config::AutoConf'     => '0.16',
                           'ExtUtils::LibBuilder' => '0.04',
                           'Test::More'           => 0,
                          },
   requires            => {
                           'perl' => 5.008,
                          },
   add_to_cleanup      => [ 'Lingua-Identify-CLD-*' ],
   create_makefile_pl  => 'traditional',
  );


## HACK  HACK  HACK  HACK
my $libdir = $builder->install_destination("bin");
my $incdir    = $libdir;
if ($^O =~ /mswin32/i) {
    $libdir = $ENV{WINDIR} || 'c:\\WINDOWS\\'; ## HACK HACK HACK
    $incdir    = undef;
} else {
    $libdir =~ s/\bbin\b/lib/;
    $incdir =~ s/\bbin\b/include/;
}

$builder->notes('libdir'   => $libdir);
$builder->notes('incdir'   => $incdir);


$builder->create_build_script();
