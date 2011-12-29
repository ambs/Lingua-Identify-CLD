use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Lingua::Identify::CLD',
    license             => 'bsd',
    dist_author         => q{Alberto Simoes <ambs@cpan.org>},
    dist_version_from   => 'lib/Lingua/Identify/CLD.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'Lingua-Identify-CLD-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
