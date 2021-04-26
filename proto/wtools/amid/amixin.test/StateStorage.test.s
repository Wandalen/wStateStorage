( function _StateStorage_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  const _ = require( '../../../node_modules/Tools' );

  _.include( 'wTesting' );

  require( '../amixin/aStateStorage.s' );

}

const _ = _global_.wTools;

// --
// context
// --

function sampleClassMake( o )
{

  _.routine.options_( sampleClassMake, arguments );

  if( !o.fileProvider )
  {
    let filesTree = { dir1 : { dir2 : { storage : '{ random : 0.6397020320139724 }', dir3 : {} } } }
    o.fileProvider = new _.FileProvider.Extract({ filesTree });
  }

  function SampleClass( o )
  {
    return _.workpiece.construct( SampleClass, this, arguments );
  }

  function init( o )
  {
    _.workpiece.initFields( this );
    Object.preventExtensions( this );
    if( o )
    _.props.extend( this, o );
    if( !o || !o.fileProvider )
    this.fileProvider.filesTree = _.cloneJust( this.fileProvider.filesTree );
  }

  let Associates =
  {
    storageFileName :  o.storageFileName,
    fileProvider :  _.define.own( o.fileProvider ),
  }

  let Extension =
  {
    init,
    Composes : _.props.extend( null, o.fieldsMap || {}, o.storeMap || {} ),
    Associates,
  }

  if( o.storageIs )
  Extension.storageIs = o.storageIs;
  if( o.storageLoaded )
  Extension.storageLoaded = o.storageLoaded;
  if( o.storageToSave )
  Extension.storageToSave = o.storageToSave;

  _.classDeclare
  ({
    cls : SampleClass,
    extend : Extension,
  });

  _.StateStorage.mixin( SampleClass );

  return SampleClass;
}

sampleClassMake.defaults =
{
  storageFileName : null,
  storageIs : null,
  storageLoaded : null,
  storageToSave : null,
  storeMap : null,
  fieldsMap : null,
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

  let storeMap =
  {
    random : null,
  }

  let fieldsMap =
  {
    storageFilePath :  '/dir1/dir2/storage',
  }

  var SampleClass = context.sampleClassMake
  ({
    storageFileName : 'storage',
    storageToSave,
    storageLoaded,
    fieldsMap,
    storeMap,
  });

  /* */

  let sample = new SampleClass();
  test.identical( sample.random, null );

  /* */

  test.case = 'defined storageFilePath cd:/';

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/storage' );
  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/storage' );
  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/storage' );

  test.description = 'storageLoad';
  sample.storageLoad();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePathToLoadGet() );
  var expected = sample.storageToSave();
  test.identical( got, expected )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/storage' );

  test.description = 'storageSave';
  sample.random = Math.random();
  sample.storageSave();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePath );
  var expected = { random : sample.random };
  test.identical( got, expected )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/storage' );

  /* */

  test.case = 'storageFilePath:null cd:/';

  sample.storageFilePath = null;
  sample.random = undefined;

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), null );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, null );

  test.description = 'storageLoad';
  test.identical( sample.storageLoad(), false )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), null );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, null );

  test.description = 'storageSave';
  sample.random = Math.random();
  sample.storageSave();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePath );
  var expected = sample.storageToSave();
  test.identical( got, expected )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/storage' );

  /* */

  test.case = 'storageFilePath:null cd:/dir1/dir2/dir3';

  sample.storageFilePath = null;
  sample.random = undefined;
  sample.fileProvider.path.current( '/dir1/dir2/dir3' );

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/dir3/storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, null );

  test.description = 'storageLoad';
  sample.storageLoad();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePathToLoadGet() );
  var expected = sample.storageToSave();
  test.identical( got, expected );

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/storage' );

  test.description = 'storageSave';
  sample.random = Math.random();
  sample.storageSave();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePath );
  var expected = { random : sample.random };
  test.identical( got, expected )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/storage' );

  test.description = 'storageSave';
  sample.storageFilePath = null;
  sample.random = Math.random();
  sample.storageSave();
  var got = sample.fileProvider.fileReadJs( sample.storageFilePath );
  var expected = { random : sample.random };
  test.identical( got, expected )

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/dir3/storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/dir3/storage' );

  test.description = 'storageFilePath';
  test.identical( sample.storageFilePath, '/dir1/dir2/dir3/storage' );

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

  let storeMap =
  {
    random : null,
  }

  var fieldsMap =
  {
  }

  var SampleClass = context.sampleClassMake
  ({
    storageFileName : 'storage',
    storageToSave,
    storageLoaded,
    storeMap,
    fieldsMap,
  });

  /* */

  let sample = new SampleClass();
  sample.fileProvider.path.current( '/dir1/dir2/dir3' );
  test.identical( sample.random, null );

  test.description = 'storageFilePathToLoadGet';
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/dir3/storage' );

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
  test.identical( sample.storageFilePathToLoadGet(), '/dir1/dir2/dir3/storage' );

  test.description = 'storageFilePathToSaveGet';
  test.identical( sample.storageFilePathToSaveGet(), '/dir1/dir2/dir3/storage' );

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
    let storage = _.props.extend( null, _.mapOnly_( null, self, StoreMap ) );
    return storage;
  }

  function storageLoaded( o )
  {
    let self = this;
    let result = _.StateStorage.prototype.storageLoaded.call( self, o );
    self.ino = o.storage.ino;
    return o.storage;
  }

  let StoreMap =
  {
    ino : null,
  }

  let FieldsMap =
  {
    storageFilePath : null,
    storageDirPath : null,
  }

  var sampleClass = self.sampleClassMake
  ({
    storageFileName : 'storage',
    storageToSave,
    storageLoaded,
    fileProvider : new _.FileProvider.Extract(),
    fieldsMap : FieldsMap,
    storeMap : StoreMap
  });

  var fields =
  {
    'ino' : 3659174697525816,
  }

  /* */

  test.case = 'storageFilePath is a root directory'
  var classInstance = new sampleClass( fields );
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/storage' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, fields );

  /* */

  test.case = 'storageFilePath does not exist'
  var classInstance = new sampleClass( _.props.extend( null, fields, { storageFilePath : '/storageFilePath' } ) );
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/storageFilePath' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, fields );

  /* */

  test.case = 'storageFilePath is terminal file'
  var classInstance = new sampleClass( _.props.extend( null, fields, { storageFilePath : '/storageFilePath' } ) );
  classInstance.fileProvider.fileWrite( classInstance.storageFilePath, 'something' )
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/storageFilePath' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, fields );

  /* */

  test.case = 'storageFilePath is directory'
  var classInstance = new sampleClass( _.props.extend( null, fields, { storageFilePath : '/storageFilePath' } ) );
  classInstance.fileProvider.filesDelete( classInstance.storageFilePath );
  classInstance.fileProvider.dirMake( classInstance.storageFilePath );
  test.shouldThrowErrorSync( () => classInstance.storageSave() );

  /* */

  test.case = 'storageFilePath is directory'
  var classInstance = new sampleClass( _.props.extend( null, fields, { storageDirPath : '/storageFilePath' } ) );
  classInstance.fileProvider.filesDelete( classInstance.storageDirPath );
  classInstance.fileProvider.dirMake( classInstance.storageDirPath );
  classInstance.storageSave();
  test.identical( classInstance.storageFilePath, '/storageFilePath/storage' )
  var got = classInstance.fileProvider.fileReadJs( classInstance.storageFilePath );
  test.identical( got, fields );

  /* */

  test.case = 'storageDirPath is array of paths, one of paths does not exist'
  var o2 =
  {
    storageDirPath : [ '/', '/some/dir' ],
    fileProvider : new _.FileProvider.Extract()
  }
  var classInstance = new sampleClass( _.props.extend( null, fields, o2 ) );
  test.identical( classInstance.storageDirPath, [ '/', '/some/dir' ] );
  test.identical( classInstance.storageFilePath, null );
  test.identical( classInstance.storageFilePathToLoadGet(), null );
  test.identical( classInstance.storageFilePathToSaveGet(), [ '/storage', '/some/dir/storage' ] );
  classInstance.storageSave();
  test.identical( classInstance.storageDirPath, [ '/', '/some/dir' ] );
  test.identical( classInstance.storageFilePath, [ '/storage', '/some/dir/storage' ] );
  test.identical( classInstance.storageFilePathToLoadGet(), [ '/storage', '/some/dir/storage' ] );
  test.identical( classInstance.storageFilePathToSaveGet(), [ '/storage', '/some/dir/storage' ] );
  var storages = classInstance.storageFilePath.map( ( p ) => classInstance.fileProvider.fileReadJs( p ) );
  test.identical( storages, [ fields, fields ] );

  /* */

  test.case = 'storageDirPath is array of paths, one of paths does not exist'
  var o2 =
  {
    storageDirPath : [ '/x', '/y' ],
    storageFilePath : [ '/storage2', '/some/dir/storage2' ],
    fileProvider : new _.FileProvider.Extract()
  }
  var classInstance = new sampleClass( _.props.extend( null, fields, o2 ) );
  test.identical( classInstance.storageDirPath, [ '/x', '/y' ] );
  test.identical( classInstance.storageFilePath, [ '/storage2', '/some/dir/storage2' ] );
  test.identical( classInstance.storageFilePathToLoadGet(), null );
  test.identical( classInstance.storageFilePathToSaveGet(), [ '/storage2', '/some/dir/storage2' ] );
  classInstance.storageSave();
  test.identical( classInstance.storageDirPath, [ '/', '/some/dir' ] );
  test.identical( classInstance.storageFilePath, [ '/storage2', '/some/dir/storage2' ] );
  test.identical( classInstance.storageFilePathToLoadGet(), [ '/storage2', '/some/dir/storage2' ] );
  test.identical( classInstance.storageFilePathToSaveGet(), [ '/storage2', '/some/dir/storage2' ] );
  var storages = classInstance.storageFilePath.map( ( p ) => classInstance.fileProvider.fileReadJs( p ) );
  test.identical( storages, [ fields, fields ] );

  var o3 =
  {
    storageDirPath : [ '/x', '/y' ],
    storageFilePath : [ '/storage2', '/some/dir/storage2' ],
    fileProvider : o2.fileProvider,
    ino : 13,
  }

  var classInstance = new sampleClass( _.props.extend( null, fields, o3 ) );
  test.identical( classInstance.storageDirPath, [ '/x', '/y' ] );
  test.identical( classInstance.storageFilePath, [ '/storage2', '/some/dir/storage2' ] );
  test.identical( classInstance.storageFilePathToLoadGet(), [ '/storage2', '/some/dir/storage2' ] );
  test.identical( classInstance.storageFilePathToSaveGet(), [ '/storage2', '/some/dir/storage2' ] );
  test.identical( classInstance.storageToSave(), { ino : 13 } );
  classInstance.storageLoad();
  test.identical( classInstance.storageDirPath, [ '/', '/some/dir' ] );
  test.identical( classInstance.storageFilePath, [ '/storage2', '/some/dir/storage2' ] );
  test.identical( classInstance.storageFilePathToLoadGet(), [ '/storage2', '/some/dir/storage2' ] );
  test.identical( classInstance.storageFilePathToSaveGet(), [ '/storage2', '/some/dir/storage2' ] );
  test.identical( classInstance.storageToSave(), { ino : 3659174697525816 } );
  var storages = classInstance.storageFilePath.map( ( p ) => classInstance.fileProvider.fileReadJs( p ) );
  test.identical( storages, [ fields, fields ] );

  /* */

  test.case = 'set storageFilePath to null'
  var o2 =
  {
    storageFilePath : null,
  }
  var classInstance = new sampleClass( _.props.extend( null, fields, o2 ) );

  test.identical( classInstance.storageDirPath, null );
  test.identical( classInstance.storageFilePath, null );
  test.identical( classInstance.storageFilePathToLoadGet(), null );
  test.identical( classInstance.storageFilePathToSaveGet(), '/storage' );
  test.identical( classInstance.storageToSave(), { ino : 3659174697525816 } );

  classInstance.storageSave();

  test.identical( classInstance.storageDirPath, '/' );
  test.identical( classInstance.storageFilePath, '/storage' );
  test.identical( classInstance.storageFilePathToLoadGet(), '/storage' );
  test.identical( classInstance.storageFilePathToSaveGet(), '/storage' );
  test.identical( classInstance.storageToSave(), { ino : 3659174697525816 } );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'storageSave does not accept any arguments'
  var classInstance = new sampleClass( _.props.extend( null, fields ) );
  test.shouldThrowErrorOfAnyKind( () => classInstance.storageSave( { storageFilePath : '/__storage' } ) )

  test.case = 'set paths to null'
  var o2 =
  {
    storageFilePath : null,
    storageFileName : null,
  }
  var classInstance = new sampleClass( _.props.extend( null, fields, o2 ) );
  test.shouldThrowErrorOfAnyKind( () => classInstance.storageSave() )

  test.case = 'set storageFileName to null'
  var o2 =
  {
    storageFileName : null
  }
  var classInstance = new sampleClass( _.props.extend( null, fields, o2 ) );
  test.shouldThrowErrorOfAnyKind( () => classInstance.storageSave() )


}

//

function storageLoad( test )
{
  var self = this;

  function storageIs( storage )
  {
    let self = this;
    return _.mapHasExactly( storage, { ino : null } );
  }

  function storageLoaded( o )
  {
    let self = this;
    let result = _.StateStorage.prototype.storageLoaded.call( self, o );
    self.ino = o.storage.ino;
    return o.storage;
  }

  function storageToSave( o )
  {
    let self = this;
    let storage = _.mapOnly_( null, self, storeMap );
    return storage;
  }

  let storeMap =
  {
    ino : null,
  }

  let fieldsMap =
  {
    storageFilePath : null,
  }

  var storeSaved =
  {
    'ino' : 3659174697525816,
  }

  var sampleClass = self.sampleClassMake
  ({
    storageFileName : 'storage',
    storageLoaded,
    storageToSave,
    storageIs,
    fileProvider : new _.FileProvider.Extract(),
    storeMap,
    fieldsMap,
  });

  /* - */

  test.open( 'load storage from existing file' );

  test.case = 'basic';
  var instance1 = new sampleClass( storeSaved );
  instance1.storageFilePath = '/dir1/dir2/storage';
  var instance2 = new sampleClass({ fileProvider : instance1.fileProvider });
  instance2.storageFilePath = '/dir1/dir2/storage';

  test.identical( instance1.storageFilePathToLoadGet(), null );
  test.identical( instance1.storageFilePathToSaveGet(), '/dir1/dir2/storage' );
  test.identical( instance1.storageFilePath, '/dir1/dir2/storage' );
  test.identical( instance2.storageFilePathToLoadGet(), null );
  test.identical( instance2.storageFilePathToSaveGet(), '/dir1/dir2/storage' );
  test.identical( instance2.storageFilePath, '/dir1/dir2/storage' );

  test.identical( instance1.storageToSave(), storeSaved );
  test.identical( instance2.storageToSave(), storeMap );
  var got = _.mapOnly_( null, instance1, storeMap );
  test.identical( got, storeSaved );
  instance1.storageSave();
  test.identical( instance1.storageToSave(), instance1.fileProvider.fileReadJs( instance1.storageFilePathToLoadGet() ) )
  instance2.storageLoad();
  test.identical( instance1.storageToSave(), storeSaved );
  test.identical( instance2.storageToSave(), storeSaved );

  test.identical( instance1.storageFilePathToLoadGet(), '/dir1/dir2/storage' );
  test.identical( instance1.storageFilePathToSaveGet(), '/dir1/dir2/storage' );
  test.identical( instance1.storageFilePath, '/dir1/dir2/storage' );
  test.identical( instance2.storageFilePathToLoadGet(), '/dir1/dir2/storage' );
  test.identical( instance2.storageFilePathToSaveGet(), '/dir1/dir2/storage' );
  test.identical( instance2.storageFilePath, '/dir1/dir2/storage' );

  /* */

  test.case = 'storageFileName:null'
  var instance1 = new sampleClass( storeSaved );
  var instance2 = new sampleClass({ fileProvider : instance1.fileProvider });

  test.identical( instance1.storageFilePathToLoadGet(), null );
  test.identical( instance1.storageFilePathToSaveGet(), '/storage' );
  test.identical( instance1.storageFilePath, null );
  test.identical( instance2.storageFilePathToLoadGet(), null );
  test.identical( instance2.storageFilePathToSaveGet(), '/storage' );
  test.identical( instance2.storageFilePath, null );

  test.identical( instance1.storageToSave(), storeSaved );
  test.identical( instance2.storageToSave(), storeMap );
  var got = _.mapOnly_( null, instance1, storeMap );
  test.identical( got, storeSaved );
  instance1.storageSave();
  test.identical( instance1.storageToSave(), instance1.fileProvider.fileReadJs( instance1.storageFilePathToLoadGet() ) )
  instance2.storageLoad();
  test.identical( instance1.storageToSave(), storeSaved );
  test.identical( instance2.storageToSave(), storeSaved );

  test.identical( instance1.storageFilePathToLoadGet(), '/storage' );
  test.identical( instance1.storageFilePathToSaveGet(), '/storage' );
  test.identical( instance1.storageFilePath, '/storage' );
  test.identical( instance2.storageFilePathToLoadGet(), '/storage' );
  test.identical( instance2.storageFilePathToSaveGet(), '/storage' );
  test.identical( instance2.storageFilePath, '/storage' );

  /* */

  test.case = 'load using only storageFilePath, file is a directory'
  var o2 =
  {
    storageFilePath : '/storage'
  }
  var instance = new sampleClass( o2 );
  instance.fileProvider.filesDelete( o2.storageFilePath );
  instance.fileProvider.dirMake( o2.storageFilePath );
  test.shouldThrowErrorOfAnyKind( () => instance.storageLoad() );

  /* */

  test.case = 'load using only storageFilePath, file is a regular file'
  var o2 =
  {
    storageFilePath : '/storage'
  }
  var instance = new sampleClass( o2 );
  instance.fileProvider.filesDelete( o2.storageFilePath );
  instance.fileProvider.fileWrite( o2.storageFilePath, o2.storageFilePath );
  test.shouldThrowErrorOfAnyKind( () => instance.storageLoad() );

  test.close( 'load storage from existing file' );

  /* - */

  test.open( 'try load not existing storage' );

  var instance = new sampleClass( { storageFilePath : '/storageFilePath' } );
  test.identical( instance.storageLoad(), false );

  test.case = 'try to provide undefined paths'
  var o2 =
  {
    storageFilePath : null,
    storageFileName : null,
  }
  var instance = new sampleClass( o2 );
  test.shouldThrowErrorOfAnyKind( () => instance.storageLoad() )

  test.case = 'try to leave storageFilePath defined'
  var o2 =
  {
    storageFileName : null
  }
  var instance = new sampleClass( o2 );
  test.shouldThrowErrorOfAnyKind( () => instance.storageLoad() )

  test.close( 'try load not existing storage' );

  if( !Config.debug )
  return;

  test.case = 'storageSave does not accept any arguments'
  var instance = new sampleClass();
  test.shouldThrowErrorOfAnyKind( () => instance.storageLoad( { storageFilePath : '/__storage' } ) )

}

//

const Proto =
{

  name : 'Tools.mid.StateStorage',
  silencing : 1,

  context :
  {
    sampleClassMake,
  },

  tests :
  {

    withStorageFilePath,
    withoutStorageFilePath,

    storageSave,
    storageLoad,

  },

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
