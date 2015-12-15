perl Makefile.PL INSTALLDIRS=site
IF errorlevel 1 exit 1

make
IF errorlevel 1 exit 1

make test
IF errorlevel 1 exit 1

make install
