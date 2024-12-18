/****************************************************************************
*
*  This code is Public Domain.
*
*  ========================================================================
*
* Description:  JWasm top level module
*
****************************************************************************/

#include <signal.h>

#include "globals.h"
#include "msgtext.h"
#include "cmdline.h"
#include "input.h" /* GetFNamePart() */

#define CATCHBREAK 0

#if defined(__UNIX__) || defined(__CYGWIN__) || defined(__DJGPP__)

#define WILDCARDS 0
#define CATCHBREAK 0

#else

#define WILDCARDS 1


#endif

#if WILDCARDS

 #ifdef __UNIX__
  #include <unistd.h>
 #else
  #include <io.h>
 #endif
#endif

#ifdef TRMEM
void tm_Init( void );
void tm_Fini( void );
#endif

int main( int argc, char **argv )
/*******************************/
{
    char    *pEnv;
    int     numArgs = 0;
    int     numFiles = 0;
    int     rc = 0;
#if WILDCARDS
    /* v2.11: _findfirst/next/close() handle, should be of type intptr_t.
     * since this type isn't necessarily defined, type long is used as substitute.
     */
    long    fh;
    const char *pfn;
    int     dirsize;
    struct  _finddata_t finfo;
    char    fname[FILENAME_MAX];
#endif

#if 0 //def DEBUG_OUT    /* DebugMsg() cannot be used that early */
    int i;
    for ( i = 1; i < argc; i++ ) {
        printf("argv[%u]=>%s<\n", i, argv[i] );
    }
#endif

#ifdef TRMEM
    tm_Init();
#endif

    pEnv = getenv( "JWASM" );
    if ( pEnv == NULL )
        pEnv = "";
    argv[0] = pEnv;


#if CATCHBREAK
    signal(SIGBREAK, genfailure);
//#else
//    signal(SIGTERM, genfailure);
#endif

    /* ParseCmdLine() returns NULL if no source file name has been found (anymore) */
    while ( ParseCmdline( (const char **)&argv[1], &numArgs ) ) {
        numFiles++;
        write_logo();
#if WILDCARDS
        if ((fh = _findfirst( Options.names[ASM], &finfo )) == -1 ) {
            DebugMsg(("main: _findfirst(%s) failed\n", Options.names[ASM] ));
            EmitErr( CANNOT_OPEN_FILE, Options.names[ASM], ErrnoStr() );
            break;
        }
        /* v2.12: _splitpath()/_makepath() removed */
        //_splitpath( Options.names[ASM], drv, dir, NULL, NULL );
        //DebugMsg(("main: _splitpath(%s): drv=\"%s\" dir=\"%s\"\n", Options.names[ASM], drv, dir ));
        pfn = GetFNamePart( Options.names[ASM] );
        dirsize = pfn - Options.names[ASM];
        memcpy( fname, Options.names[ASM], dirsize );
        do {
            /* v2.12: _splitpath()/_makepath() removed */
            //_makepath( fname, drv, dir, finfo.name, NULL );
            //DebugMsg(("main: _makepath(\"%s\", \"%s\", \"%s\")=\"%s\"\n", drv, dir, finfo.name, fname ));
            strcpy( &fname[dirsize], finfo.name );
            DebugMsg(("main: fname=%s\n", fname ));
            rc = AssembleModule( fname );  /* assemble 1 module */
        } while ( ( _findnext( fh, &finfo ) != -1 ) );
        _findclose( fh );
#else
        rc = AssembleModule( Options.names[ASM] );
#endif
    };
    CmdlineFini();
    if ( numArgs == 0 ) {
        write_logo();
        printf( "%s", MsgGetEx( MSG_USAGE ) );
    } else if ( numFiles == 0 )
        EmitError( NO_FILENAME_SPECIFIED );

#ifdef TRMEM
    tm_Fini();
#endif

    DebugMsg(("main: exit, return code=%u\n", 1 - rc ));
    return( 1 - rc ); /* zero if no errors */
}
