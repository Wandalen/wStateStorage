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

// context

function sampleClassMake( o )
{
  function SampleClass( o )
  {
    return _.instanceConstructor( SampleClass, this, arguments );
  }

  function init( o )
  {
    let sample = this;
    _.instanceInit( sample );

    if( o )
    sample.copy( o );
  }

  let Associates =
  {
    opened : 0,
    storageFileName :  o.storageFileName,
    storageFilePath :  o.storageFilePath,
    fileProvider :  _.define.own( o.fileProvider ),
  }

  let Extend =
  {
    init : init,
    storageLoaded : o.storageLoaded,
    storageToSave : o.storageToSave,
    Composes : o.Composes,
    Associates : Associates,
  }

  _.classDeclare
  ({
    cls : SampleClass,
    extend : Extend,
  });

  _.StateStorage.mixin( SampleClass );
  _.Copyable.mixin( SampleClass );

  return SampleClass;
}

// tests

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

function storageSave( test )
{
  var self = this;

  function storageToSave( op )
  {
    let self = this;
    let storage = _.mapExtend( null, _.mapOnly( self, Composes ) );
    return storage;
  }
  let Composes =
  {
    dev : null,
    mode : null,
    nlink : null,
    uid : null,
    gid : null,
    rdev : null,
    ino : null,
    size : null,
    atime : null,
    mtime : null,
    ctime : null,
    birthtime : null,
  }
  var sampleClass = self.sampleClassMake
  ({
    storageFileName : '.storage',
    storageFilePath : '/',
    storageToSave : storageToSave,
    fileProvider : new _.FileProvider.Extract(),
    Composes : Composes,
  });
  var o =
  {
    "dev" : 2523469189,
    "mode" : 33206,
    "nlink" : 1,
    "uid" : 0,
    "gid" : 0,
    "rdev" : 0,
    "ino" : 3659174697525816,
    "size" : 4263,
    "atime" : new Date( '2018-08-23T18:46:22.481Z' ),
    "mtime" : new Date( '2018-10-03T15:25:57.946Z' ),
    "ctime" : new Date( '2018-10-03T15:25:57.946Z' ),
    "birthtime" : new Date( '2018-08-23T18:46:22.481Z' )
  }

  /* */

  test.case = 'storageFilePath is a root directory'
  var classInstance = new sampleClass( o );
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/.storage' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, o );

  //

  test.case = 'storageFilePath does not exist'
  var classInstance = new sampleClass( _.mapExtend( null, o, { storageFilePath : '/storageFilePath' } ) );
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/storageFilePath' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, o );

  //

  test.case = 'storageFilePath is terminal file'
  var classInstance = new sampleClass( _.mapExtend( null, o, { storageFilePath : '/storageFilePath' } ) );
  classInstance.fileProvider.fileWrite( classInstance.storageFilePath, 'something' )
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/storageFilePath' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, o );

  //

  test.case = 'storageFilePath is directory'
  var classInstance = new sampleClass( _.mapExtend( null, o, { storageFilePath : '/storageFilePath' } ) );
  classInstance.fileProvider.fileDelete( classInstance.storageFilePath );
  classInstance.fileProvider.directoryMake( classInstance.storageFilePath );
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/storageFilePath/.storage' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, o );

  //

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

  function storageLoaded( storage, op )
  {
    let self = this;
    let result = _.StateStorage.prototype.storageLoaded.call( self, storage, op );

    self.copy( storage );

    return storage;
  }
  function storageToSave( op )
  {
    let self = this;
    let storage = _.mapExtend( null, _.mapOnly( self, Composes ) );
    return storage;
  }
  let Composes =
  {
    dev : null,
    mode : null,
    nlink : null,
    uid : null,
    gid : null,
    rdev : null,
    ino : null,
    size : null,
    atime : null,
    mtime : null,
    ctime : null,
    birthtime : null,
  }
  var sampleClass = self.sampleClassMake
  ({
    storageFileName : '.storage',
    storageFilePath : '/',
    storageLoaded : storageLoaded,
    storageToSave : storageToSave,
    fileProvider : new _.FileProvider.Extract(),
    Composes : Composes,
  });
  var o =
  {
    "dev" : 2523469189,
    "mode" : 33206,
    "nlink" : 1,
    "uid" : 0,
    "gid" : 0,
    "rdev" : 0,
    "ino" : 3659174697525816,
    "size" : 4263,
    "atime" : new Date( '2018-08-23T18:46:22.481Z' ),
    "mtime" : new Date( '2018-10-03T15:25:57.946Z' ),
    "ctime" : new Date( '2018-10-03T15:25:57.946Z' ),
    "birthtime" : new Date( '2018-08-23T18:46:22.481Z' )
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
  test.identical( got, o );

  //

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

  //

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

  //

  test.case = 'load using only storageFilePath, file is a directory'
  var o2 =
  {
    storageFilePath : '/.storage'
  }
  var classInstance = new sampleClass( o2 );
  classInstance.fileProvider.fileDelete( o2.storageFilePath );
  classInstance.fileProvider.directoryMake( o2.storageFilePath );
  test.shouldThrowError( () => classInstance.storageLoad() );

  //

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
  // verbosity : 1,

  context :
  {
    sampleClassMake : sampleClassMake,
  },

  tests :
  {
    trivial : trivial,
    storageSave : storageSave,
    storageLoad : storageLoad,


  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
