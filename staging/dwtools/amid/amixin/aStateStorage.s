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
//
// --

function _storageFileSaveAct( o )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let logger = self.logger || _global_.logger;

  _.routineOptions( _storageFileSaveAct, o );
  _.assert( o.storage !== undefined && !_.routineIs( o.storage ), () => 'Expects defined data {-self.storageToSave-}' );
  _.assert( arguments.length === 1 );

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

  /* xxx */

  if( self.storageSavingAsJs )
  fileProvider.fileWriteJs( o2 );
  else
  fileProvider.fileWriteJson( o2 );

}

_storageFileSaveAct.defaults =
{
  storageFilePath : null,
  splitting : 0,
  storage : null,
}

//

function _storageFileSave( o )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let logger = self.logger || _global_.logger;

  _.assert( fileProvider.path.isAbsolute( o.storageFilePath ) );
  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.routineOptions( _storageFileSave, arguments );
  _.assert( _.routineIs( self.storageToSave ) );

  o.storage = self.storageToSave( o );

  self._storageFileSaveAct( o );

}

_storageFileSave.defaults =
{
  storageFilePath : null,
  splitting : 0,
}

//

function _storageSave( o )
{
  let self = this;
  let fileProvider = self.fileProvider;

  if( !_.mapIs( o ) )
  o = { storageFilePath : o }

  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );
  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.routineOptions( _storageSave, o );

  o.storageFilePath = o.storageFilePath || self.storageFilePathToSaveGet();

  if( _.arrayIs( o.storageFilePath ) )
  for( let p = 0 ; p < o.storageFilePath.length ; p++ )
  self._storageFileSave
  ({
    storageFilePath : o.storageFilePath[ p ],
    splitting : 1,
  })
  else
  self._storageFileSave
  ({
    storageFilePath : o.storageFilePath,
    splitting : 0,
  });

  return true;
}

_storageSave.defaults =
{
  storageFilePath : null,
}

//

function storageSave()
{
  let self = this;
  // debugger;
  let storageFilePath = self.storageFilePathToSaveGet();
  // debugger;

  _.assert( arguments.length === 0 );
  _.assert( !!storageFilePath, () => 'not clear where to save ' + _.toStrShort( storageFilePath ) );

  if( self.storageFilePath !== undefined )
  self.storageFilePath = storageFilePath;

  return self._storageSave({ storageFilePath : storageFilePath });
}

// {
//   let self = this;
//   _.assert( arguments.length === 0 );
//   return self._storageSave();
// }

//

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

  o.read = fileProvider.fileReadJs( o.storageFilePath );

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

  // o.storageDirPath = self.storageDirPathGet( o.storageDirPath );
  o.storageDirPath = path.resolve( o.storageDirPath || '.' );
  o.storageFilePath = o.storageFilePath || self.storageFileName;
  o.storageFilePath = path.s.join( o.storageDirPath, o.storageFilePath );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( !!o.storageFilePath );
  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );
  _.routineOptions( _storageFilesRead, o );

  let result = Object.create( null );

  _.each( o.storageFilePath, ( storageFilePath ) =>
  {
    let op = Object.create( null );
    op.storageFilePath = storageFilePath;
    self._storageFileRead( op );
    result[ op.storageFilePath ] = op;
    // result = self.storageLoaded( read, op ) && result;
  });

  return result;
}

_storageFilesRead.defaults =
{
  storageDirPath : null,
  storageFilePath : null,
}

//

function storageLoad()
{
  let self = this;
  let storageFilePath = self.storageFilePathToLoadGet();

  _.assert( arguments.length === 0 );
  _.assert( !!storageFilePath );

  // if( !storageFilePath )
  // return storageFilePath;
  //
  // if( self.storageFilePath !== undefined )
  // self.storageFilePath = storageFilePath;

  let read = self._storageFilesRead({ storageFilePath : storageFilePath });
  let result = true;

  _.each( read, ( op, storageFilePath ) =>
  {
    result = self.storageLoaded( op ) && result;
  });

  return result;
}

//
//
// function storageDirPathGet( storageDirPath )
// {
//   let self = this;
//   let fileProvider = self.fileProvider;
//
//   _.assert( arguments.length === 0 || arguments.length === 1 );
//
//   storageDirPath = fileProvider.path.resolve( storageDirPath || null );
//
//   _.assert( fileProvider.path.isAbsolute( storageDirPath ) );
//
//   return storageDirPath;
// }

//

function storageFileFromDirPath( storageDirPath )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = self.path;
  let storageFilePath = null;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );

  // storageDirPath = self.storageDirPathGet( storageDirPath );

  storageDirPath = path.resolve( storageDirPath );

  storageFilePath = fileProvider.path.s.join( storageDirPath , self.storageFileName );

  return storageFilePath;
}

//

function _storageFilePathGet( storageDirPath )
{
  let self = this;
  let fileProvider = self.fileProvider;

  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( !self.storageFilePath )
  return;

  let storageFilePath = self.storageFilePath;

  // let storageFilePath = self.storageFileFromDirPath( storageDirPath );
  // debugger;

  storageFilePath = _.map( storageFilePath, ( storageFilePath ) =>
  {
    if( fileProvider.directoryIs( storageFilePath ) )
    return fileProvider.path.join( storageFilePath , self.storageFileName );
    else
    return storageFilePath;
  });

  return storageFilePath;
}

//

function storageFilePathToLoadGet( storageDirPath )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );

  if( !storageDirPath && self.storageFilePath !== undefined )
  storageDirPath = self.storageFilePath;

  let storageFilePath;
  if( self.storageFilePath )
  {
    storageFilePath = self._storageFilePathGet( storageDirPath );
  }
  else
  {
    // storageDirPath = self.storageDirPathGet( storageDirPath );
    storageDirPath = path.resolve( storageDirPath );
    do
    {
      storageFilePath =  fileProvider.path.join( storageDirPath , self.storageFileName );
      if( fileProvider.fileExists( storageFilePath ) )
      return storageFilePath;
      storageDirPath = fileProvider.path.dir( storageDirPath );
    }
    while( storageDirPath !== '/..' );
  }

  if( storageDirPath === '/..' )
  return null;

  _.sure
  (
    _.all( storageFilePath, ( storageFilePath ) => fileProvider.fileStat( storageFilePath ) ),
    () => 'Storage file does not exist ' + _.strQuote( storageFilePath )
  );

  return storageFilePath;
}

//

function storageFilePathToSaveGet( storageDirPath )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let storageFilePath = null;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );

  if( !storageDirPath && self.storageFilePath !== undefined )
  storageDirPath = self.storageFilePath;

  if( self.storageFilePath )
  {
    storageFilePath = self._storageFilePathGet( storageDirPath );
  }
  else
  {
    storageFilePath = self.storageFileFromDirPath( storageDirPath );
  }

  _.sure
  (
    _.all( storageFilePath, ( storageFilePath ) => fileProvider.directoryIs( fileProvider.path.dir( storageFilePath ) ) ),
    () => 'Directory for storage file does not exist ' + _.strQuote( storageFilePath )
  );

  return storageFilePath;
}

//

function storageIs( storage )
{
  let self = this;
  _.assert( arguments.length === 1 );
  if( !_.objectIs( storage ) )
  return false;
  return true;
}

//

/*
!!! move out
*/

function storageLoaded( o )
{
  let self = this;
  let fileProvider = self.fileProvider;

  _.sure( self.storageIs( o.storage ), () => 'Strange storage : ' + _.toStrShort( o.storage ) );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.storageFilePath ) );

  if( self.storagesLoaded !== undefined )
  {
    _.assert( _.arrayIs( self.storagesLoaded ), () => 'expects {-self.storagesLoaded-}, but got ' + _.strTypeOf( self.storagesLoaded ) );
    self.storagesLoaded.push({ filePath : o.storageFilePath });
  }

  if( self.storage !== undefined )
  self.storage = _.mapExtend( self.storage, o.storage );

  return true;
}

//

function storageToSave( op )
{
  let self = this;
  let storage = self.storage;
  _.assert( storage !== undefined, '{-self.storage-} is not defined' );
  return storage;
}

// --
//
// --

let Has =
{
  storageFileName : null,
}

let Composes =
{
  /* storageFileName : '.storage', */
  /* storageFilePath : null, */
  storageSavingAsJs : 1,
}

let Aggregates =
{
}

let Associates =
{
  /* fileProvider : null, */
}

let Restricts =
{
  /* storageToSave : null, */
  /* storagesLoaded : _.define.own( [] ), */
  /* opened : 0, */
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
  // storageFilePath : 'storageFilePath',
}

let Accessors =
{
}

// --
// declare
// --

let Supplement =
{

  _storageFileSaveAct : _storageFileSaveAct,
  _storageFileSave : _storageFileSave,
  _storageSave : _storageSave,
  storageSave : storageSave,

  _storageFileRead : _storageFileRead,
  _storageFilesRead : _storageFilesRead,
  storageLoad : storageLoad,

  // storageDirPathGet : storageDirPathGet,
  storageFileFromDirPath : storageFileFromDirPath,
  _storageFilePathGet : _storageFilePathGet,

  storageFilePathToLoadGet : storageFilePathToLoadGet,
  storageFilePathToSaveGet : storageFilePathToSaveGet,

  storageIs : storageIs,
  storageLoaded : storageLoaded,
  storageToSave : storageToSave,

  //

  Has : Has,
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
