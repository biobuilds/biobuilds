perl Build.PL
IF errorlevel 1 exit 1

Build
IF errorlevel 1 exit 1

Build test
IF errorlevel 1 exit 1

Build install --installdirs site
