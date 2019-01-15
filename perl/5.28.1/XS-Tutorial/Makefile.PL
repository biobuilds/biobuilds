use 5.008005;
use ExtUtils::MakeMaker 7.12; # for XSMULTI option

WriteMakefile(
  NAME           => 'XS::Tutorial',
  VERSION_FROM   => 'lib/XS/Tutorial.pm',
  PREREQ_PM      => { 'ExtUtils::MakeMaker' => '7.12' },
  ABSTRACT_FROM  => 'lib/XS/Tutorial.pm',
  AUTHOR         => 'David Farrell',
  CCFLAGS        => '-Wall -std=c99',
  OPTIMIZE       => '-O3',
  LICENSE        => 'BSD',
  XSMULTI        => 1,
);
