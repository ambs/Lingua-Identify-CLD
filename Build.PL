use 5.008;
use strict;
use warnings;

use lib 'inc';
use Config;

use MyBuilder;

my $builder = MyBuilder->new
  (
   module_name         => 'Lingua::Identify::CLD',
   license             => 'bsd',
   dist_author         => q{Alberto Simões <ambs@cpan.org>},
   dist_version_from   => 'lib/Lingua/Identify/CLD.pm',
   build_requires      => {
                           'Config::AutoConf'     => '0.17',
                           'ExtUtils::CBuilder'   => '0.27',
                           'ExtUtils::ParseXS'    => 0,
                           'ExtUtils::LibBuilder' => '0.04',
                           'Test::More'           => 0,
                          },
   configure_requires  => {
                           'Config::AutoConf'     => '0.16',
                           'Module::Build'        => '0.38',
                           'ExtUtils::LibBuilder' => '0.04',
                          },
   requires            => {
                           'XSLoader' => '0.10',
                           'perl' => 5.008,
                          },
   add_to_cleanup      => [
                           '*.o',
                           'cld-src/*.dylib',
                           'cld-src/*.so',
                           'cld-src/*.dll',
                           'cld-src/*.o',
                           'cld-src/*/*.o',
                           'cld-src/*/*/*.o',
                           'cld-src/*/*/*/*.o',
                           'Lingua-Identify-CLD-*'
                          ],
  );


## HACK  HACK  HACK  HACK
my $libdir = $builder->install_destination("bin");
if ($^O =~ /mswin32/i) {
    $libdir = $ENV{WINDIR} || 'c:\\WINDOWS\\'; ## HACK HACK HACK
} else {
    if ($Config{archname} =~ /^x86_64/) {
        $libdir =~ s/\bbin\b/lib64/;
        if (!-d $libdir) {
            my $test = $libdir;
            $test =~ s/lib64/lib/;
            $libdir = $test if -d $test;
        }
    } else {
        $libdir =~ s/\bbin\b/lib/;
    }
}
$builder->notes('libdir'   => $libdir);
$builder->notes('lib_path' => $libdir);

$builder->add_build_element('usrlib');
$builder->install_path( 'usrlib' => $libdir );

$builder->create_build_script;
