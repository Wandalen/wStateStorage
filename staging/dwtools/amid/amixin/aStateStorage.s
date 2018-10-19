( function _StateStorage_s_() {

'use strict';

/**
  @module Tools/mid/StateStorage - Mixin to add persistent state storing functionality to a class. StateStorage solves the common problem to persistently store the state of an object. It let save the state in a specific moment ( for example on process exit ) and to restore the state later ( for example on process start ). Use the module to be more cross-platform, don't repeat yourself and forget about details of implementation you don't worry.
*/

/**
 * @file files/StateStorage.s.
 */

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  let _ = _global_.wTools;

  _.include( 'wProto' );
  _.include( 'wFiles' );

}

//

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wStateStorage( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'StateStorage';

// --
// save
// --

function _storageFileWrite( o )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;
  let logger = self.logger || _global_.logger;

  _.routineOptions( _storageFileWrite, o );
  _.assert( o.storage !== undefined && !_.routineIs( o.storage ), () => 'Expects defined data {-o.storage-}' );
  _.assert( arguments.length === 1 );
  _.assert( path.isAbsolute( o.storageFilePath ) );
  _.assert( _.strDefined( self.storageFileName ), 'expects string field {-storageFileName-}' );
  _.assert( _.routineIs( self.storageToSave ) );

  if( logger.verbosity >= 3 )
  {
    let title = _.strQuote( _.strCapitalize( _.strToTitle( self.storageFileName ) ) );
    logger.log( ' + saving config ' + title + ' at ' + _.strQuote( o.storageFilePath ) );
  }

  let o2 =
  {
    filePath : o.storageFilePath,
    data : o.storage,
    pretty : 1,
    sync : 1,
  }

  /* xxx : replace by write encoders */

  if( self.storageSavingAsJs )
  fileProvider.fileWriteJs( o2 );
  else
  fileProvider.fileWriteJson( o2 );

}

_storageFileWrite.defaults =
{
  storageFilePath : null,
  splitting : 0,
  storage : null,
}

//

function _storageFilesWrite( o )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;

  if( !_.mapIs( o ) )
  o = { storageFilePath : o }

  _.assert( _.strDefined( self.storageFileName ), 'expects string field {-storageFileName-}' );
  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.routineOptions( _storageFilesWrite, o );

  o.storageFilePath = o.storageFilePath || self.storageFilePathToSaveGet();

  let isVector = _.arrayIs( o.storageFilePath );
  _.each( o.storageFilePath, ( storageFilePath ) =>
  {
    let op = Object.create( null );
    op.storageFilePath = storageFilePath;
    op.splitting = isVector;
    op.storage = self.storageToSave( o );
    self._storageFileWrite( op );
  });

  return true;
}

_storageFilesWrite.defaults =
{
  storageFilePath : null,
}

//

function storageSave()
{
  let self = this;
  let storageFilePath = self.storageFilePathToSaveGet();
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( !!storageFilePath, () => 'not clear where to save ' + _.toStrShort( storageFilePath ) );

  let result = self._storageFilesWrite({ storageFilePath : storageFilePath });

  self.storageFilePathApply( storageFilePath );

  return result;
}

//

function storageToSave( o )
{
  let self = this;
  let storage = self.storage;
  _.assert( storage !== undefined, '{-self.storage-} is not defined' );
  // _.sure( self.storageIs( storage ), () => 'Strange storage : ' + _.toStrShort( storage ) );
  self.storageCheck( storage );
  _.routineOptions( storageToSave, arguments );
  return storage;
}

storageToSave.defaults =
{
  storageFilePath : null,
  splitting : 0,
  storage : null,
}

// --
// load
// --

function _storageFileRead( o )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;
  let logger = self.logger || _global_.logger;

  if( !_.mapIs( o ) )
  o = { storageFilePath : o }

  _.routineOptions( _storageFileRead, o );
  _.assert( path.isAbsolute( o.storageFilePath ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( !fileProvider.fileStat( o.storageFilePath ) )
  return false;

  /* */

  if( logger.verbosity >= 3 )
  {
    let title = _.strQuote( _.strCapitalize( _.strToTitle( self.storageFileName ) ) );
    logger.log( ' . loading config ' + title + ' at ' + _.strQuote( o.storageFilePath ) );
  }

  o.storage = fileProvider.fileReadJs( o.storageFilePath );

  // let result = self.storageLoaded( read, o );

  return o;
}

_storageFileRead.defaults =
{
  storageFilePath : null,
}

//

function _storageFilesRead( o )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;
  let logger = self.logger || _global_.logger;

  if( !_.mapIs( o ) )
  o = { storageDirPath : o }

  // o.storageDirPath = path.resolve( o.storageDirPath || '.' );
  o.storageDirPath = o.storageDirPath || '.';
  o.storageFilePath = o.storageFilePath || self.storageFileName;
  o.storageFilePath = path.s.join( o.storageDirPath, o.storageFilePath );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( !!o.storageFilePath );
  _.assert( _.strDefined( self.storageFileName ), 'expects string field {-storageFileName-}' );
  _.assert( path.s.allAreAbsolute( o.storageFilePath ), 'expects absolute paths {-o.storageFilePath-}' );
  _.routineOptions( _storageFilesRead, o );

  let result = Object.create( null );

  _.each( o.storageFilePath, ( storageFilePath ) =>
  {
    let op = Object.create( null );
    op.storageFilePath = storageFilePath;
    self._storageFileRead( op );
    result[ op.storageFilePath ] = op;
  });

  return result;
}

_storageFilesRead.defaults =
{
  storageDirPath : null,
  storageFilePath : null,
}

//

/*
should not throw error if cant load file, but return false
*/

function storageLoad()
{
  let self = this;
  let storageFilePath = self.storageFilePathToLoadGet();

  _.assert( arguments.length === 0 );
  // _.sure( !!storageFilePath, 'Cant load storage : not found' );

  if( !storageFilePath )
  return false;

  let read = self._storageFilesRead({ storageFilePath : storageFilePath });
  let result = true;
  let storageFilePaths = [];

  _.each( read, ( op, storageFilePath ) =>
  {
    let loaded = self.storageLoaded( op );
    result = loaded && result;
    if( loaded )
    storageFilePaths.push( storageFilePath );
  });

  if( storageFilePaths.length < 2 )
  storageFilePaths = storageFilePaths[ 0 ] || null;

  self.storageFilePathApply( storageFilePath );

  return result;
}

//

function storageLoaded( o )
{
  let self = this;
  let fileProvider = self.fileProvider;

  self.storageCheck( o.storage );
  _.assert( arguments.length === 1 );
  _.routineOptions( storageLoaded, arguments );

  if( self.storagesLoaded !== undefined )
  {
    debugger;
    _.assert( _.arrayIs( self.storagesLoaded ), () => 'Expects array {-self.storagesLoaded-}, but got ' + _.strTypeOf( self.storagesLoaded ) );
    _.assert( _.strIs( o.storageFilePath ), 'Expects string {-self.storagesLoaded-}' );
    self.storagesLoaded.push({ filePath : o.storageFilePath });
  }

  if( self.storage !== undefined )
  self.storage = _.mapExtend( self.storage, o.storage );

  return true;
}

storageLoaded.defaults =
{
  storage : null,
  storageFilePath : null,
}

// --
// path
// --

function storageFilePathApply( storageFilePath )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;

  _.assert( storageFilePath === null || path.s.allAre( storageFilePath ) );

  if( storageFilePath === null )
  {
    if( self.storageFilePath !== undefined )
    self.storageFilePath = null;
    if( self.storageDirPath !== undefined )
    self.storageDirPath = null;
    return false;
  }

  if( self.storageFilePath !== undefined )
  self.storageFilePath = storageFilePath;
  if( self.storageDirPath !== undefined )
  self.storageDirPath = path.s.dir( storageFilePath );

  return _.strIs( storageFilePath ) || storageFilePath.length > 0;
}

//

function storageFileFromDirPath( storageDirPath )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;
  let storageFilePath = null;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.strDefined( self.storageFileName ), 'expects string field {-storageFileName-}' );

  // storageDirPath = path.s.resolve( storageDirPath );
  storageFilePath = path.s.join( storageDirPath , self.storageFileName );

  return storageFilePath;
}

//

function storagePathGet( o )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.strDefined( self.storageFileName ), 'expects string field {-storageFileName-}' );
  o = _.routineOptions( storagePathGet, o );

  /* */

  let pathsDefined = o.storageDirPath || o.storageFilePath;
  if( !pathsDefined && self.storageFilePath !== undefined )
  o.storageFilePath = self.storageFilePath;
  if( !pathsDefined && self.storageDirPath !== undefined )
  o.storageDirPath = self.storageDirPath;

  /* */

  if( !o.storageDirPath && o.storageFilePath )
  o.storageDirPath = path.s.dir( o.storageFilePath );
  o.storageDirPath = path.s.resolve( o.storageDirPath );

  if( !o.storageFilePath )
  o.storageFilePath = self.storageFileFromDirPath( o.storageDirPath );
  o.storageFilePath = path.s.resolve( o.storageDirPath, o.storageFilePath );

  o.storageDirPath = path.s.dir( o.storageFilePath );

  return o;
}

storagePathGet.defaults =
{
  storageDirPath : null,
  storageFilePath : null,
}

//

function storageFilePathToLoadGet( o )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;
  let result;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  o = self.storagePathGet( o );

  [ o.storageFilePath, o.storageDirPath ] = _.multipleAll([ o.storageFilePath, o.storageDirPath ]);

  /* */

  if( _.arrayIs( o.storageFilePath ) )
  {
    result = Object.create( null );
    result.storageFilePath = [];
    result.storageDirPath = [];
    for( let s = 0 ; s < o.storageFilePath.length ; s++ )
    {
      let r = forPath({ storageFilePath : o.storageFilePath[ s ], storageDirPath : o.storageDirPath[ s ] });
      if( r !== null )
      {
        result.storageFilePath.push( r.storageFilePath );
        result.storageDirPath.push( r.storageDirPath );
      }
    }
    if( !result.storageFilePath.length )
    {
      result.storageFilePath = null;
      result.storageDirPath = null;
    }
  }
  else
  {
    result = forPath( o ) || { storageFilePath : null };
  }

  /* */

  _.sure
  (
    result.storageFilePath === null || _.all( result.storageFilePath, ( storageFilePath ) => fileProvider.fileStat( storageFilePath ) ),
    () => 'Storage file does not exist ' + _.toStr( o )
  );

  return result.storageFilePath;

  /* - */

  function forPath( o )
  {

    o.storageFilePath = path.join( o.storageDirPath, o.storageFilePath );

    if( !fileProvider.fileExists( o.storageFilePath ) )
    do
    {
      o.storageFilePath = path.join( o.storageDirPath, self.storageFileName );
      if( fileProvider.fileExists( o.storageFilePath ) )
      break;
      o.storageDirPath = path.dir( o.storageDirPath );
    }
    while( o.storageDirPath !== '/..' );

    if( o.storageDirPath === '/..' )
    {
      return null;
      // o.storageDirPath = null;
      // o.storageFilePath = null;
      // return o;
    }

    return o;
  }

}

storageFilePathToLoadGet.defaults =
{
  storageDirPath : null,
  storageFilePath : null,
}

//

function storageFilePathToSaveGet( o )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  o = self.storagePathGet( o );

  let good = _.all( o.storageFilePath, ( storageFilePath ) =>
  {
    let dir = path.dir( storageFilePath );
    return !fileProvider.fileExists( dir ) || fileProvider.directoryIs( dir );
  })

  _.sure( good, () => 'Directory for storage file does not exist ' + _.strQuote( o.storageFilePath ) );

  return o.storageFilePath;
}

storageFilePathToSaveGet.defaults =
{
  storageDirPath : null,
  storageFilePath : null,
}

// --
// etc
// --

function storageIs( storage )
{
  let self = this;
  _.assert( arguments.length === 1 );
  if( !_.objectIs( storage ) )
  return false;
  return true;
}

//

function storageCheck( storage )
{
  let self = this;
  _.assert( arguments.length === 1 );
  if( !self.storageIs( storage ) )
  throw _.err( 'Strange storage :\n' + _.toStr( storage, { levels : 2, multiline : 1, wrap : 0 } ) );
}

//

function storageDefaultGet()
{
  let self = this;
  _.assert( arguments.length === 0 );
  let op = Object.create( null );
  op.storageFilePath = self.storagePathGet().storageFilePath;
  op.storage = self.storageToSave( op );

  let defaults = self.Self.fieldsOfRelationsGroups;
  for( let s in op.storage )
  {
    _.sureBriefly( defaults[ s ] !== undefined, 'Not clear what is default value for field', s );
    op.storage[ s ] = defaults[ s ];
  }

  return op;
}

// --
// relations
// --

let MustHave =
{
  storageFileName : null,
  fileProvider : null,
}

let CouldHave =
{
  storageFilePath : null,
  storageDirPath : null,
  storage : null,
  storagesLoaded : null,
}

let Composes =
{
  storageSavingAsJs : 1,
}

let Aggregates =
{
}

let Associates =
{
}

let Restricts =
{
}

let Statics =
{
}

let Forbids =
{
  storageFor : 'storageFor',
  loadedStorages : 'loadedStorages',
  storageDirPathGet : 'storageDirPathGet',
  _storageLoad : '_storageLoad',
  _storageFileLoad : '_storageFileLoad',
  _storageFileSaveAct : '_storageFileSaveAct',
  _storageFilePathGet : '_storageFilePathGet',
  storageFilePathGet : 'storageFilePathGet',
}

let Accessors =
{
}

// --
// declare
// --

let Supplement =
{

  // save

  _storageFileWrite : _storageFileWrite,
  _storageFilesWrite : _storageFilesWrite,
  storageSave : storageSave,
  storageToSave : storageToSave,

  // load

  _storageFileRead : _storageFileRead,
  _storageFilesRead : _storageFilesRead,
  storageLoad : storageLoad,
  storageLoaded : storageLoaded,

  // path

  storageFilePathApply : storageFilePathApply,
  storageFileFromDirPath : storageFileFromDirPath,
  storagePathGet : storagePathGet,
  storageFilePathToLoadGet : storageFilePathToLoadGet,
  storageFilePathToSaveGet : storageFilePathToSaveGet,

  // etc

  storageIs : storageIs,
  storageCheck : storageCheck,
  storageDefaultGet : storageDefaultGet,

  //

  MustHave : MustHave,
  CouldHave : CouldHave,

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Forbids : Forbids,
  Accessors : Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  supplement : Supplement,
  withMixin : true,
  withClass : true,
});

// --
// export
// --

_global_[ Self.name ] = _[ Self.shortName ] = Self;

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
