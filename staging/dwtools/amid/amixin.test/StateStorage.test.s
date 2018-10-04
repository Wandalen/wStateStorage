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

var _ = _global_.wTools;

// --
// context
// --

function sampleClassMake( o )
{

  _.routineOptions( sampleClassMake, arguments );

  if( !o.fileProvider )
  {
    let filesTree = { dir1 : { dir2 : { '.storage' : "{ random : 0.6397020320139724 }", dir3 : {} } } }
    o.fileProvider = new _.FileProvider.Extract({ filesTree : filesTree });
  }

  function SampleClass( o )
  {
    return _.instanceConstructor( SampleClass, this, arguments );
  }

  function init( o )
  {
    _.instanceInit( this );
  }

  let Associates =
  {
    storageFileName :  o.storageFileName,
    fileProvider :  _.define.own( o.fileProvider ),
  }

  let Extend =
  {
    init : init,
    storageLoaded : o.storageLoaded,
    storageToSave : o.storageToSave,
    Composes : o.fields,
    Associates : Associates,
  }

  _.classDeclare
  ({
    cls : SampleClass,
    extend : Extend,
  });

  _.StateStorage.mixin( SampleClass );

  return SampleClass;
}

sampleClassMake.defaults =
{
  storageFileName : null,
  storageLoaded : null,
  storageToSave : null,
  fields : null,
  fileProvider : null,
}

// --
// tests
// --

function withStorageFilePath( test )
{
  let context = this;

  function storageLoaded( o )
  {
    let self = this;
    let result = _.StateStorage.prototype.storageLoaded.call( self, o );
    self.random = o.storage.random;
    return result;
  }

  function storageToSave( o )
  {
    let self = this;
    let storage = { random : self.random };
    return storage;
  }

  let Composes =
  {
    storageFilePath :  '/dir1/dir2/.storage',
  }

  var SampleClass = context.sampleClassMake
  ({
    storageFileName : '.storage',
    storageToSave : storageToSave,
    storageLoaded : storageLoaded,
    fields : Composes,
  });

  /* */

  let sample = new SampleClass();
  test.identical( sample.random, undefined );

  /* */

  test.case = 'defined storageFilePath cd:/';

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/.storage' );

  test.description = 'storageLoad';
  sample.storageLoad();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePathToLoadGet() );
  var expected = sample.storageToSave();
  test.identical( got, expected )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/.storage' );

  test.description = 'storageSave';
  sample.random = Math.random();
  sample.storageSave();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePath );
  var expected = { random : sample.random };
  test.identical( got, expected )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/.storage' );

  /* */

  test.case = 'storageFilePath:null cd:/';

  sample.storageFilePath = null;
  sample.random = undefined;

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), null );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, null );

  test.description = 'storageLoad';
  test.shouldThrowErrorSync( () =>
  {
    sample.storageLoad();
  });

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), null );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, null );

  test.description = 'storageSave';
  sample.random = Math.random();
  sample.storageSave();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePath );
  var expected = sample.storageToSave();
  test.identical( got, expected )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/.storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/.storage' );

  /* */

  test.case = 'storageFilePath:null cd:/dir1/dir2/dir3';

  sample.storageFilePath = null;
  sample.random = undefined;
  sample.fileProvider.path.current( '/dir1/dir2/dir3' );

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/dir3/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, null );

  test.description = 'storageLoad';
  sample.storageLoad();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePathToLoadGet() );
  var expected = sample.storageToSave();
  test.identical( got, expected );

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/.storage' );

  test.description = 'storageSave';
  sample.random = Math.random();
  sample.storageSave();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePath );
  var expected = { random : sample.random };
  test.identical( got, expected )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/.storage' );

  test.description = 'storageSave';
  sample.storageFilePath = null;
  sample.random = Math.random();
  sample.storageSave();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePath );
  var expected = { random : sample.random };
  test.identical( got, expected )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/dir3/.storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/dir3/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/dir3/.storage' );

}

//

function withoutStorageFilePath( test )
{
  let context = this;

  function storageLoaded( o )
  {
    let self = this;
    let result = _.StateStorage.prototype.storageLoaded.call( self, o );
    self.random = o.storage.random;
    return result;
  }

  function storageToSave( o )
  {
    let self = this;
    let storage = { random : self.random };
    return storage;
  }

  let Composes =
  {
  }

  var SampleClass = context.sampleClassMake
  ({
    storageFileName : '.storage',
    storageToSave : storageToSave,
    storageLoaded : storageLoaded,
    fields : Composes,
  });

  /* */

  let sample = new SampleClass();
  sample.fileProvider.path.current( '/dir1/dir2/dir3' );
  test.identical( sample.random, undefined );

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/.storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/dir3/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, undefined );

  test.description = 'storageLoad';
  sample.storageLoad();
  var expected = sample.fileProvider.fileReadJs( sample.storageFilePathToLoadGet() );
  test.identical( sample.storageToSave(), expected );
  sample.random = Math.random();

  test.description = 'storageSave';
  sample.storageSave();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePathToLoadGet() );
  var expected = { random : sample.random };
  test.identical( got, expected )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/dir3/.storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/dir3/.storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, undefined );

}

//

function storageSave( test )
{
  var self = this;

  function storageToSave( o )
  {
    let self = this;
    let storage = _.mapExtend( null, _.mapOnly( self, Composes ) );
    return storage;
  }
  let Composes =
  {
    ino : null,
  }

  var sampleClass = self.sampleClassMake
  ({
    storageFileName : '.storage',
    storageToSave : storageToSave,
    fileProvider : new _.FileProvider.Extract(),
    fields : Composes,
  });

  var o =
  {
    "ino" : 3659174697525816,
  }

  /* */

  test.case = 'storageFilePath is a root directory'
  var classInstance = new sampleClass( o );
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/.storage' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, o );

  /* */

  test.case = 'storageFilePath does not exist'
  var classInstance = new sampleClass( _.mapExtend( null, o, { storageFilePath : '/storageFilePath' } ) );
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/storageFilePath' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, o );

  /* */

  test.case = 'storageFilePath is terminal file'
  var classInstance = new sampleClass( _.mapExtend( null, o, { storageFilePath : '/storageFilePath' } ) );
  classInstance.fileProvider.fileWrite( classInstance.storageFilePath, 'something' )
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/storageFilePath' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, o );

  /* */

  test.case = 'storageFilePath is directory'
  var classInstance = new sampleClass( _.mapExtend( null, o, { storageFilePath : '/storageFilePath' } ) );
  classInstance.fileProvider.fileDelete( classInstance.storageFilePath );
  classInstance.fileProvider.directoryMake( classInstance.storageFilePath );
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/storageFilePath/.storage' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, o );

  /* */

  test.case = 'storageFilePath is array of paths, one of paths does not exist'
  var o2 =
  {
    storageFilePath : [ '/', '/storageFilePath' ],
    fileProvider : new _.FileProvider.Extract()
  }
  var classInstance = new sampleClass( _.mapExtend( null, o, o2 ) );
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, [ '/.storage', '/storageFilePath' ] );
  var storages = classInstance.storageFilePath.map( ( p ) => classInstance.fileProvider.fileReadJs( p ) );
  test.identical( storages, [ o, o ] );

  /* */

  if( !Config.debug )
  return;

  test.case = 'storageSave does not accept any arguments'
  var classInstance = new sampleClass( _.mapExtend( null, o ) );
  test.shouldThrowError( () => classInstance.storageSave( { storageFilePath : '/__storage' } ) )

  test.case = 'set paths to null'
  var o2 =
  {
    storageFilePath : null,
    storageFileName : null,
  }
  var classInstance = new sampleClass( _.mapExtend( null, o, o2 ) );
  test.shouldThrowError( () => classInstance.storageSave() )

  test.case = 'set storageFilePath to null'
  var o2 =
  {
    storageFilePath : null
  }
  var classInstance = new sampleClass( _.mapExtend( null, o, o2 ) );
  test.shouldThrowError( () => classInstance.storageSave() )

  test.case = 'set storageFileName to null'
  var o2 =
  {
    storageFileName : null
  }
  var classInstance = new sampleClass( _.mapExtend( null, o, o2 ) );
  test.shouldThrowError( () => classInstance.storageSave() )


}

//

function storageLoad( test )
{
  var self = this;

  function storageLoaded( o )
  {
    let self = this;
    let result = _.StateStorage.prototype.storageLoaded.call( self, o );
    self.ino = o.storage;
    return o.storage;
  }
  function storageToSave( o )
  {
    let self = this;
    let storage = _.mapOnly( self, Composes );
    return storage;
  }

  let Composes =
  {
    ino : null,
  }
  var sampleClass = self.sampleClassMake
  ({
    storageFileName : '.storage',
    // storageFilePath : '/',
    storageLoaded : storageLoaded,
    storageToSave : storageToSave,
    fileProvider : new _.FileProvider.Extract(),
    fields : Composes,
  });
  var o =
  {
    "ino" : 3659174697525816,
  }

  var mainInstance = new sampleClass( o );
  mainInstance.storageSave();

  /* */

  test.open( 'load storage from existing file' );

  test.case = 'basic'
  var classInstance = new sampleClass();
  var got = _.mapOnly( classInstance, Composes );
  test.identical( got, Composes );
  classInstance.storageLoad();
  var got = _.mapOnly( classInstance, o );
  debugger;
  test.identical( got, o );
  debugger;

  /* */

  test.case = 'load using only storageFileName'
  var o2 =
  {
    storageFilePath : null
  }
  var classInstance = new sampleClass( o2 );
  var got = _.mapOnly( classInstance, Composes );
  test.identical( got, Composes );
  classInstance.storageLoad();
  var got = _.mapOnly( classInstance, o );
  test.identical( got, o );

  /* */

  test.case = 'load using only storageFilePath'
  var o2 =
  {
    storageFilePath : '/.storage'
  }
  var classInstance = new sampleClass( o2 );
  var got = _.mapOnly( classInstance, Composes );
  test.identical( got, Composes );
  classInstance.storageLoad();
  var got = _.mapOnly( classInstance, o );
  test.identical( got, o );

  /* */

  test.case = 'load using only storageFilePath, file is a directory'
  var o2 =
  {
    storageFilePath : '/.storage'
  }
  var classInstance = new sampleClass( o2 );
  classInstance.fileProvider.fileDelete( o2.storageFilePath );
  classInstance.fileProvider.directoryMake( o2.storageFilePath );
  test.shouldThrowError( () => classInstance.storageLoad() );

  /* */

  test.case = 'load using only storageFilePath, file is a regular file'
  var o2 =
  {
    storageFilePath : '/.storage'
  }
  var classInstance = new sampleClass( o2 );
  classInstance.fileProvider.fileDelete( o2.storageFilePath );
  classInstance.fileProvider.fileWrite( o2.storageFilePath, o2.storageFilePath );
  test.shouldThrowError( () => classInstance.storageLoad() );

  test.close( 'load storage from existing file' );

  /* */

  test.open( 'try load not existing storage' );

  var classInstance = new sampleClass( { storageFilePath : '/storageFilePath' } );
  test.shouldThrowError( () => classInstance.storageLoad() );

  test.case = 'try to provide undefined paths'
  var o2 =
  {
    storageFilePath : null,
    storageFileName : null,
  }
  var classInstance = new sampleClass(  o2 );
  test.shouldThrowError( () => classInstance.storageLoad() )

  test.case = 'try to leave storageFilePath defined'
  var o2 =
  {
    storageFileName : null
  }
  var classInstance = new sampleClass( o2 );
  test.shouldThrowError( () => classInstance.storageLoad() )

  test.close( 'try load not existing storage' );

  /* */

  if( !Config.debug )
  return;

  test.case = 'storageSave does not accept any arguments'
  var classInstance = new sampleClass();
  test.shouldThrowError( () => classInstance.storageLoad( { storageFilePath : '/__storage' } ) )
}

//

var Self =
{

  name : 'Tools/mid/StateStorage',
  silencing : 1,

  context :
  {
    sampleClassMake : sampleClassMake,
  },

  tests :
  {

    withStorageFilePath : withStorageFilePath,
    withoutStorageFilePath : withoutStorageFilePath,

    storageSave : storageSave,
    storageLoad : storageLoad,

  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
