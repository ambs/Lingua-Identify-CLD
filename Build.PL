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
                           'Config::AutoConf' => '0.16',
                           'Test::More'       => 0,
                          },
   requires            => {
                           'perl' => 5.008,
                          },
   add_to_cleanup      => [ 'Lingua-Identify-CLD-*' ],
   create_makefile_pl  => 'traditional',
  );

$builder->create_build_script();
