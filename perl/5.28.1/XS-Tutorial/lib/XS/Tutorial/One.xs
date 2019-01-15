#define PERL_NO_GET_CONTEXT // we'll define thread context if necessary (faster)
#include "EXTERN.h"         // globals/constant import locations
#include "perl.h"           // Perl symbols, structures and constants definition
#include "XSUB.h"           // xsubpp functions and macros
#include <stdlib.h>         // rand, srand

// additional c code goes here

MODULE = XS::Tutorial::One  PACKAGE = XS::Tutorial::One
PROTOTYPES: ENABLE

 # XS code goes here

 # XS comments begin with " #" to avoid them being interpreted as C
 # pre-processor directives

unsigned int
rand()

void
srand(seed)
  unsigned int seed
