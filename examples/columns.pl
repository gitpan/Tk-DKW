#! /usr/bin/perl

use Tk;

use Tk::Columns;

my $l_MainWindow = Tk::MainWindow->new();

my $l_Columns = $l_MainWindow->Columns
   (
    '-columnlabels' => [qw (Permissions Links Owner Group Size Month Day Time Name)],
    '-command' => sub {printf ("Selected [%s]\n", join ('|', @_));}
   );

$l_Columns->pack
   (
    '-expand' => 'true',
    '-fill' => 'both',
   );

if (open (FILE, '<testfile.txt'))
   {
    while (<FILE>)
       {
        chomp;
        $_ =~ s/[\r\n]*$//;
        $l_Columns->insert ('end', split());
       }

    close (FILE);
   }

Tk::MainLoop();