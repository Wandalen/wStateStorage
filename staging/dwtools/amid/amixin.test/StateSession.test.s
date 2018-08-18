( function _StateSession_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = wTools;
  _.include( 'wTesting' );

  require( '../amixin/aStateSession.s' );

}

var _ = wTools;

//

function trivial( test )
{
  test.identical( 1,1 );
}

//

var Self =
{

  name : 'Tools/mid/StateSession',
  silencing : 1,

  tests :
  {
    trivial : trivial,
  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
