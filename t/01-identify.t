#!perl -T

use utf8;

use Test::More;

use Lingua::Identify::CLD;

my %langs = (
             GERMAN => q{Deutschland, Deutschland über alles, Über alles in der Welt, Wenn es stets zu Schutz und Trutze Brüderlich zusammenhält. Von der Maas bis an die Memel, Von der Etsch bis an den Belt, Deutschland, Deutschland über alles, Über alles in der Welt! },
             ITALIAN => q{Fratelli d'Italia, l'Italia s'è desta, dell'elmo di Scipio s'è cinta la testa. Dov'è la Vittoria? Le porga la chioma, ché schiava di Roma Iddio la creò.},
             FRENCH => q{Allons enfants de la Patrie, Le jour de gloire est arrivé! Contre nous de la tyrannie, L'étendard sanglant est levé, Entendez-vous dans les campagnes Mugir ces féroces soldats?},
             PORTUGUESE => q{As armas e os barões assinalados, que da ocidental praia lusitana, passaram ainda além da traprobana},
             ENGLISH => q{confiscation of goods is assigned as the penalty part most of the courts consist of members and when it is necessary to bring public cases before a jury of members two courts combine for the purpose the most important cases of all are brought jurors or},
             HINDI => q{
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
});

plan tests => scalar(keys %langs);

my $cld = Lingua::Identify::CLD->new();
for my $lang (keys %langs) {
    is ($cld->identify($langs{$lang}), $lang, "Identifying $lang");
}
