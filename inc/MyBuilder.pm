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



sub ACTION_install {
    my $self = shift;

    my $usrlib = $self->install_path( 'usrlib' );

    if ($^O =~ /cygwin/i) { # cygwin uses windows lib searching (PATH instead of LD_LIBRARY_PATH)
        $self->install_path( 'usrlib' => '/usr/local/bin' );
    }
    elsif (defined $self->{properties}{install_base}) {
        $usrlib = catdir($self->{properties}{install_base} => 'lib');
        $self->install_path( 'usrlib' => $usrlib );
    }
    $self->SUPER::ACTION_install;
    if ($^O =~ /linux/ && $ENV{USER} eq 'root') {
        my $linux = Config::AutoConf->check_prog("ldconfig");
        system $linux if (-x $linux);
    }
    if ($^O =~ /(?:linux|bsd|sun|sol|dragonfly|hpux|irix|darwin)/
        &&
        $usrlib !~ m!^/usr(/local)?/lib/?$!)
      {
          warn "\n** WARNING **\n"
             . "It seems you are installing in a non standard path.\n"
             . "You might need to add $usrlib to your library search path.\n";
      }
}

sub ACTION_code {
    my $self = shift;

    my $libbuilder = ExtUtils::LibBuilder->new;
    $self->notes(libbuilder => $libbuilder);

    $self->notes(CFLAGS  => '-fPIC -I. -O2 -DCLD_WINDOWS'); # XXX fixme for windows
    $self->notes(LDFLAGS => '-L.');

    $self->dispatch("create_objects");
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

    my $extra_linker_flags = "-Lcld-src -lcld -lstdc++";
    $extra_linker_flags .= " -lgcc_s" if $^O eq 'netbsd';

    my $objects = [ $ofile ];
    # .o => .(a|bundle)
    my $lib_file = catfile( $archdir, "CLD.$Config{dlext}" );
    if ( !$self->up_to_date( [ @$objects ], $lib_file ) ) {
        my $btparselibdir = $self->install_path('usrlib');
        $cbuilder->link(
                        module_name => 'Lingua::Identify::CLD',
                        extra_linker_flags => $extra_linker_flags,
                        objects     => $objects,
                        lib_file    => $lib_file,
                       );
    }
}

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

sub ACTION_test {
    my $self = shift;

    if ($^O =~ /mswin32/i) {
        $ENV{PATH} = catdir($self->blib,"usrlib").";$ENV{PATH}";
    } elsif ($^O =~ /darwin/i) {
        $ENV{DYLD_LIBRARY_PATH} = catdir($self->blib,"usrlib");
    }
    elsif ($^O =~ /(?:linux|bsd|sun|sol|dragonfly|hpux|irix)/i) {
        my $oldlibpath = $ENV{LD_LIBRARY_PATH} || '/lib:/usr/lib';
        $ENV{LD_LIBRARY_PATH} = catdir($self->blib,"usrlib").":$oldlibpath";
     }
    elsif ($^O =~ /aix/i) {
        my $oldlibpath = $ENV{LIBPATH} || '/lib:/usr/lib';
        $ENV{LIBPATH} = catdir($self->blib,"usrlib").":$oldlibpath";
    }
    $self->SUPER::ACTION_test
}


1;
