package MyBuilder;
use base 'Module::Build';
use warnings;
use strict;
use Config;
use Carp;
use Config::AutoConf;

use ExtUtils::LibBuilder;
use File::Spec::Functions qw.catdir catfile.;
use File::Path qw.mkpath.;

my @SOURCES = map { "cld-src/$_" }
  (
   qw{encodings/compact_lang_det/cldutil.cc
      encodings/compact_lang_det/cldutil_dbg_empty.cc
      encodings/compact_lang_det/compact_lang_det.cc
      encodings/compact_lang_det/compact_lang_det_impl.cc
      encodings/compact_lang_det/ext_lang_enc.cc
      encodings/compact_lang_det/getonescriptspan.cc
      encodings/compact_lang_det/letterscript_enum.cc
      encodings/compact_lang_det/tote.cc
      encodings/compact_lang_det/generated/cld_generated_score_quadchrome_0406.cc
      encodings/compact_lang_det/generated/compact_lang_det_generated_cjkbis_0.cc
      encodings/compact_lang_det/generated/compact_lang_det_generated_ctjkvz.cc
      encodings/compact_lang_det/generated/compact_lang_det_generated_deltaoctachrome.cc
      encodings/compact_lang_det/generated/compact_lang_det_generated_quadschrome.cc
      encodings/compact_lang_det/win/cld_htmlutils_windows.cc
      encodings/compact_lang_det/win/cld_unilib_windows.cc
      encodings/compact_lang_det/win/cld_utf8statetable.cc
      encodings/compact_lang_det/win/cld_utf8utils_windows.cc
      encodings/internal/encodings.cc
      languages/internal/languages.cc}
  );


use ExtUtils::ParseXS;
use ExtUtils::Mkbootstrap;


# my $pedantic = $ENV{AMBS_PEDANTIC} || 0;

# sub ACTION_pre_install {
#     my $self = shift;

#     # Fix the path to the library in case the user specified it during install
#     if (defined $self->{properties}{install_base}) {
#         my $usrlib = catdir($self->{properties}{install_base} => 'lib');
#         $self->install_path( 'usrlib' => $usrlib );
#         warn "libjspell.so will install on $usrlib. Be sure to add it to your LIBRARY_PATH\n"
#     }

#     if ($^O ne "MSWin32") {
#         # Create and prepare for installation the .pc file if not under windows.
#         _interpolate('jspell.pc.in' => 'jspell.pc',
#                      VERSION    => $self->notes('version'),
#                      EXECPREFIX => $self->install_destination('bin'),
#                      LIBDIR     => $self->install_destination('usrlib'));
#         $self->copy_if_modified( from   => "jspell.pc",
#                                  to_dir => catdir('blib','pcfile'),
#                                  flatten => 1 );

#         $self->copy_if_modified( from   => catfile('src','jslib.h'),
#                                  to_dir => catdir('blib','incdir'),
#                                  flatten => 1);
#     }

#     ## FIXME - usar o Module::Build para isto?
#     for (qw.ujspell jspell-dict jspell-installdic.) {
#         $self->copy_if_modified( from   => catfile("scripts",$_),
#                                  to_dir => catdir('blib','script'),
#                                  flatten => 1 );
#         $self->make_executable( catfile('blib','script',$_ ));
#     }
# }

# sub ACTION_fakeinstall {
#     my $self = shift;
#     $self->dispatch("pre_install");
#     $self->SUPER::ACTION_fakeinstall;
# }

# sub ACTION_install {
#     my $self = shift;
#     $self->dispatch("pre_install");
#     $self->SUPER::ACTION_install;

#     # Run ldconfig if root
#     if ($^O =~ /linux/ && $ENV{USER} eq 'root') {
#         my $ldconfig = Config::AutoConf->check_prog("ldconfig");
#         system $ldconfig if (-x $ldconfig);
#     }

#     print STDERR "Type 'jspell-installdic pt en' to install portuguese and english dictionaries.\n";
#     print STDERR "Note that dictionary installation should be performed by a superuser account.\n";
# }

sub ACTION_code {
    my $self = shift;

#     for my $path (catdir("blib","bindoc"),
#                   catdir("blib","pcfile"),
#                   catdir("blib","incdir"),
#                   catdir("blib","script"),
#                   catdir("blib","bin")) {
#         mkpath $path unless -d $path;
#     }

    my $libbuilder = ExtUtils::LibBuilder->new;
    $self->notes(libbuilder => $libbuilder);

#     my $x = $self->notes('libdir');
#     $x =~ s/\\/\\\\/g;
#     _interpolate("src/jsconfig.in" => "src/jsconfig.h",
#                  VERSION => $self->notes('version'),
#                  LIBDIR  => $x,
#                 );

    $self->notes(CFLAGS  => '-fPIC -I. -O2 -DCLD_WINDOWS'); # XXX fixme for windows
    $self->notes(LDFLAGS => '-L.');

    $self->dispatch("create_objects");

#     $self->dispatch("create_manpages");
    $self->dispatch("create_library");

    $self->dispatch("compile_xscode");

    $self->SUPER::ACTION_code;
}


sub ACTION_compile_xscode {
    my $self = shift;
    my $cbuilder = $self->cbuilder;

    my $archdir = catdir( $self->blib, 'arch', 'auto', 'Lingua', 'Identify', 'CLD');
    mkpath( $archdir, 0, 0777 ) unless -d $archdir;

    print STDERR "\n** Preparing XS code\n";
    my $cfile = catfile("CLD.cc");
    my $xsfile= catfile("CLD.xs");
    my $ofile = catfile("CLD.o");

    $self->add_to_cleanup($cfile); ## FIXME
    if (!$self->up_to_date($xsfile, $cfile)) {
        ExtUtils::ParseXS::process_file( filename   => $xsfile,
                                         'C++'      => 1,
                                         prototypes => 0,
                                         output     => $cfile);
    }

    $self->add_to_cleanup($ofile); ## FIXME

    my $extra_compiler_flags = $self->notes('CFLAGS');
    $Config{ccflags} =~ /(-arch \S+(?: -arch \S+)*)/ and $extra_compiler_flags .= " $1";

    if (!$self->up_to_date($cfile, $ofile)) {
        $cbuilder->compile( source               => $cfile,
                            include_dirs         => [ catdir("cld-src") ],
                            'C++'                => 1,
                            extra_compiler_flags => $extra_compiler_flags,
                            object_file          => $ofile);
    }

    # Create .bs bootstrap file, needed by Dynaloader.
    my $bs_file = catfile( $archdir, "CLD.bs" );
    if ( !$self->up_to_date( $ofile, $bs_file ) ) {
        ExtUtils::Mkbootstrap::Mkbootstrap($bs_file);
        if ( !-f $bs_file ) {
            # Create file in case Mkbootstrap didn't do anything.
            open( my $fh, '>', $bs_file ) or confess "Can't open $bs_file: $!";
        }
        utime( (time) x 2, $bs_file );    # touch
    }

    my $objects = [ $ofile ];
    # .o => .(a|bundle)
    my $lib_file = catfile( $archdir, "CLD.$Config{dlext}" );
    if ( !$self->up_to_date( [ @$objects ], $lib_file ) ) {
        my $btparselibdir = $self->install_path('usrlib');
        $cbuilder->link(
                        module_name => 'Lingua::Identify::CLD',
                        extra_linker_flags => "-Lcld-src -lcld -lstdc++",
                        objects     => $objects,
                        lib_file    => $lib_file,
                       );
    }
}


# sub ACTION_create_manpages {
#     my $self = shift;

#     my $pods = $self->rscan_dir("src", qr/\.pod$/);

#     my $version = $self->notes('version');
#     for my $pod (@$pods) {
#         my $man = $pod;
#         $man =~ s!.pod!.1!;
#         $man =~ s!src!catdir("blib","bindoc")!e;
#         next if $self->up_to_date($pod, $man);
#         ## FIXME
#         `pod2man --section=1 --center="Lingua::Jspell" --release="Lingua-Jspell-$version" $pod $man`;
#     }

#     my $pod = 'scripts/jspell-dict';
#     my $man = catfile('blib','bindoc','jspell-dict.1');
#     unless ($self->up_to_date($pod, $man)) {
#         `pod2man --section=1 --center="Lingua::Jspell" --release="Lingua-Jspell-$version" $pod $man`;
#     }

#     $pod = 'scripts/jspell-installdic';
#     $man = catfile('blib','bindoc','jspell-installdic.1');
#     unless ($self->up_to_date($pod, $man)) {
#         `pod2man --section=1 --center="Lingua::Jspell" --release="Lingua-Jspell-$version" $pod $man`;
#     }
# }

sub ACTION_create_objects {
    my $self = shift;
    my $cbuilder = $self->cbuilder;

    my $extra_compiler_flags = $self->notes('CFLAGS');
    $Config{ccflags} =~ /(-arch \S+(?: -arch \S+)*)/ and $extra_compiler_flags .= " $1";

    for my $file (@SOURCES) {
        my $object = $file;
        $object =~ s/\.cc/.o/;
        next if $self->up_to_date($file, $object);
        $cbuilder->compile(object_file  => $object,
                           source       => $file,
                           include_dirs => ["cld-src"],
                           extra_compiler_flags => $extra_compiler_flags,
                           'C++' => 1);
    }
}


# sub ACTION_create_binaries {
#     my $self = shift;
#     my $cbuilder = $self->cbuilder;

#     my $libbuilder = $self->notes('libbuilder');
#     my $EXEEXT = $libbuilder->{exeext};
#     my $extralinkerflags = $self->notes('lcurses').$self->notes('ccurses');

#     my @toinstall;
#     my $exe_file = catfile("src" => "jspell$EXEEXT");
#     $self->config_data("jspell" => catfile($self->config_data("bindir") => "jspell$EXEEXT"));
#     push @toinstall, $exe_file;
#     my $object   = catfile("src" => "jmain.o");
#     my $libdir   = $self->install_path('usrlib');
#     if (!$self->up_to_date($object, $exe_file)) {
#         $libbuilder->link_executable(exe_file => $exe_file,
#                                      objects  => [ $object ],
#                                      extra_linker_flags => "-Lsrc -ljspell $extralinkerflags");
#     }

#     $exe_file = catfile("src","jbuild$EXEEXT");
#     $self->config_data("jbuild" => catfile($self->config_data("bindir") => "jbuild$EXEEXT"));
#     push @toinstall, $exe_file;
#     $object   = catfile("src","jbuild.o");
#     if (!$self->up_to_date($object, $exe_file)) {
#         $libbuilder->link_executable(exe_file => $exe_file,
#                                      objects  => [ $object ],
#                                      extra_linker_flags => "-Lsrc -ljspell $extralinkerflags");
#     }

#     for my $file (@toinstall) {
#         $self->copy_if_modified( from    => $file,
#                                  to_dir  => "blib/bin",
#                                  flatten => 1);
#     }
# }

sub ACTION_create_library {
    my $self = shift;
    my $cbuilder = $self->cbuilder;

    my $libbuilder = $self->notes('libbuilder');
    my $LIBEXT = $libbuilder->{libext};

    my $o_files = $self->rscan_dir('cld-src', qr/\.o$/);


    my $libpath = $self->notes('libdir');
    $libpath = catfile($libpath, "libcld$LIBEXT");
    my $libfile = catfile("cld-src","libcld$LIBEXT");

    my $extralinkerflags = "";
    $extralinkerflags.=" -install_name $libpath" if $^O =~ /darwin/;

    if (!$self->up_to_date($o_files, $libfile)) {
        $libbuilder->link(module_name => 'libcld',
                          extra_linker_flags => $extralinkerflags,
                          'C++' => 1,
                          objects => $o_files,
                          lib_file => $libfile,
                         );
    }

    my $libdir = catdir($self->blib, 'usrlib');
    mkpath( $libdir, 0, 0777 ) unless -d $libdir;

    $self->copy_if_modified( from   => $libfile,
                             to_dir => $libdir,
                             flatten => 1 );
}

# sub ACTION_test {
#     my $self = shift;

#     if ($^O =~ /mswin32/i) {
#         $ENV{PATH} = catdir($self->blib,"usrlib").";$ENV{PATH}";
#     } elsif ($^O =~ /darwin/i) {
#         $ENV{DYLD_LIBRARY_PATH} = catdir($self->blib,"usrlib");
#     }
#     elsif ($^O =~ /(?:linux|bsd|sun|sol|dragonfly|hpux|irix)/i) {
#         $ENV{LD_LIBRARY_PATH} = catdir($self->blib,"usrlib");
#     }
#     elsif ($^O =~ /aix/i) {
#         my $oldlibpath = $ENV{LIBPATH} || '/lib:/usr/lib';
#         $ENV{LIBPATH} = catdir($self->blib,"usrlib").":$oldlibpath";
#     }

#     $self->SUPER::ACTION_test
# }


# sub _interpolate {
#     my ($from, $to, %config) = @_;
	
#     print "Creating new '$to' from '$from'.\n";
#     open FROM, $from or die "Cannot open file '$from' for reading.\n";
#     open TO, ">", $to or die "Cannot open file '$to' for writing.\n";
#     while (<FROM>) {
#         s/\[%\s*(\S+)\s*%\]/$config{$1}/ge;		
#         print TO;
#     }
#     close TO;
#     close FROM;
# }


1;
