package Lingua::Identify::CLD;

use 5.006;
use strict;
use warnings;


=head1 NAME

Lingua::Identify::CLD - Interface to Chrome language detection library.

=head1 VERSION

Version 0.02_01

=cut

our $VERSION = '0.02_01';

use XSLoader;
BEGIN {
    XSLoader::load('Lingua::Identify::CLD', $VERSION);
}

=head1 SYNOPSIS

    use Lingua::Identify::CLD;

    my $cld = Lingua::Identify::CLD->new();

    my $lang = $cld->identify("Text");

=head1 METHODS

=head2 new

Constructs a CLD object.

=cut

sub new {
    my ($class, %options) = @_;
    my $self = {%options};
    return bless $self => $class # amen
}

=head2 identify

Receives a string, returns a language name.

=cut

sub identify {
    my ($self, $text, %options) = @_;

    return _identify($text);
}

=head1 AUTHOR

Alberto Simoes, C<< <ambs at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
L<http://github.com/ambs/Lingua-Identify-CLD>.  I will be notified,
and then you'll automatically be notified of progress on your bug as I
make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Lingua::Identify::CLD


You can also look for information at:

=over 4

=item * Git repository and ticket tracker

L<http://github.com/ambs/Lingua-Identify-CLD>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Lingua-Identify-CLD>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Lingua-Identify-CLD>

=item * Search CPAN

L<http://search.cpan.org/dist/Lingua-Identify-CLD/>

=back


=head1 ACKNOWLEDGEMENTS

Chrome team for making the code available.

Jean Véronis for pushing me to do this.

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alberto Simoes.

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/bsd-license.php>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of Alberto Simoes's Organization
nor the names of its contributors may be used to endorse or promote
products derived from this software without specific prior written
permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Lingua::Identify::CLD
