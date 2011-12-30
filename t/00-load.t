#!perl -T

use utf8;

use Test::More tests => 1;

BEGIN {
    use_ok( 'Lingua::Identify::CLD' ) || print "Bail out!\n";
}

my $eng = <<EOE;
  confiscation of goods is assigned as the penalty part most of the courts 
  consist of members and when it is necessary to bring public cases before a 
  jury of members two courts combine for the purpose the most important cases 
  of all are brought jurors or
EOE

my $hindi = <<EOI;
  नेपाल एसिया 
  मंज अख मुलुक
   राजधानी काठ
  माडौं नेपाल 
  अधिराज्य पेर
  ेग्वाय 
  दक्षिण अमेरि
  का महाद्वीपे
   मध् यक्षेत्
  रे एक देश अस
  ् ति फणीश्वर
   नाथ रेणु 
  फिजी छु दक्ष
  िण प्रशान् त
   महासागर मंज
   अख देश बहाम
  ास छु केरेबि
  यन मंज 
  अख मुलुख राज
  धानी नसौ सम्
   बद्घ विषय ब
  ुरुंडी अफ्री
  का महाद्वीपे
   मध् 
  यक्षेत्रे दे
  श अस् ति सम्
   बद्घ विषय
EOI


diag( "Testing Lingua::Identify::CLD $Lingua::Identify::CLD::VERSION, Perl $], $^X" );

Lingua::Identify::CLD::identify($eng);
Lingua::Identify::CLD::identify($hindi);
