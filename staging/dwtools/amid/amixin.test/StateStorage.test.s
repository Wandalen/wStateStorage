( function _StateStorage_test_s_( ) {

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

  require( '../amixin/aStateStorage.s' );

}

var _ = wTools;

//

function trivial( test )
{
  let filesTree = { 'storage' : "{ random : 0.6397020320139724 }" }
  let fileProvider = new _.FileProvider.Extract({ filesTree : filesTree });

  function SomeClass( o )
  {
    return _.instanceConstructor( SomeClass, this, arguments );
  }

  function init( o )
  {
    let sample = this;
    _.instanceInit( sample );
  }

  function storageLoaded( storage, op )
  {
    let self = this;
    let result = _.StateStorage.prototype.storageLoaded.call( self, storage, op );

    self.random = storage.random;

    return result;
  }

  function storageToSave( op )
  {
    let self = this;

    let storage = { random : self.random };

    return storage;
  }

  let Associates =
  {
    opened : 0,
    storageFileName :  'storage',
    storageFilePath :  '/storage',
    fileProvider :  _.define.own( fileProvider ),
  }

  let Extend =
  {
    init : init,
    storageLoaded : storageLoaded,
    storageToSave : storageToSave,
    Associates : Associates,
  }

  _.classDeclare
  ({
    cls : SomeClass,
    extend : Extend,
  });

  _.StateStorage.mixin( SomeClass );

  /* */

  let sample = new SomeClass();
  test.identical( sample.random, undefined );
  sample.storageLoad();
  var expected = sample.fileProvider.fileReadJs( sample.storageFilePath );
  test.identical( sample.random, expected.random );
  sample.random = Math.random();
  sample.storageSave();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePath );
  var expected = { random : sample.random };
  test.identical( got, expected )
  // console.log( 'sample.random', sample.storageFilePathToLoadGet(), sample.random );

  /* */

  test.identical( 1,1 );

}

//

var Self =
{

  name : 'Tools/mid/StateStorage',
  silencing : 1,
  // verbosity : 1,

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
