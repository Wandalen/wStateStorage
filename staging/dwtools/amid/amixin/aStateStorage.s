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
  _.assert( arguments.length === 0 || arguments.length === 1, 'expects single argument' );
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

  let options =
  {
    filePath : o.storageFilePath,
    data : o.storage,
    pretty : 1,
    sync : 1,
  }

  if( self.storageSavingAsJs )
  fileProvider.fileWriteJs( options );
  else
  fileProvider.fileWriteJson( options );
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

function _storageFileLoad( o )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let logger = self.logger || _global_.logger;

  if( !_.mapIs( o ) )
  o = { storageFilePath : o }

  _.routineOptions( _storageFileLoad, o );
  _.assert( fileProvider.path.is( o.storageFilePath ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( !fileProvider.fileStat( o.storageFilePath ) )
  return false;

  /* */

  if( logger.verbosity >= 3 )
  {
    let title = _.strQuote( _.strCapitalize( _.strToTitle( self.storageFileName ) ) );
    logger.log( ' . loading config ' + title + ' at ' + _.strQuote( o.storageFilePath ) );
  }

  let read = fileProvider.fileReadJs( o.storageFilePath );

  let result = self.storageLoaded( read, o );

  return result;
}

_storageFileLoad.defaults =
{
  storageFilePath : null,
}

//

function _storageLoad( o )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let logger = self.logger || _global_.logger;

  if( !_.mapIs( o ) )
  o = { storageDirPath : o }

  o.storageDirPath = self.storageDirPathGet( o.storageDirPath );
  o.storageFilePath = o.storageFilePath || self.storageFileName;
  o.storageFilePath = _.path.s.join( o.storageDirPath, o.storageFilePath );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( !!o.storageFilePath );
  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );
  _.routineOptions( _storageLoad, o );

  let result = true;
  _.each( o.storageFilePath, ( path ) =>
  {
    result = self._storageFileLoad( path ) && result;
  });

  return result;
  // if( !fileProvider.fileStat( o.storageFilePath ) )
  // return false;
  //
  // for( let f = 0 ; f < self.loadedStorages.length ; f++ )
  // {
  //   let loadedStorage = self.loadedStorages[ f ];
  //   if( _.strBegins( o.storageDirPath,loadedStorage.dirPath ) && ( o.storageFilePath !== loadedStorage.filePath ) )
  //   return false;
  // }
  //
  // if( logger.verbosity >= 4 )
  // logger.log( '. loading ' + _.strReplaceAll( self.storageFileName,'.','' ) + ' ' + o.storageFilePath );
  // let mapExtend = fileProvider.fileReadJs( o.storageFilePath );
  //
  // let extended = self.storageLoaded( o.storageFilePath, mapExtend );
  //
  // if( extended )
  // self.loadedStorages.push({ dirPath : o.storageDirPath, filePath : o.storageFilePath });
  //
  // return extended;
}

_storageLoad.defaults =
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

  if( !storageFilePath )
  return storageFilePath;

  if( self.storageFilePath !== undefined )
  self.storageFilePath = storageFilePath;

  return self._storageLoad({ storageFilePath : storageFilePath });
}

//

function storageDirPathGet( storageDirPath )
{
  let self = this;
  let fileProvider = self.fileProvider;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  storageDirPath = fileProvider.path.resolve( storageDirPath || null );

  _.assert( fileProvider.path.isAbsolute( storageDirPath ) );

  return storageDirPath;
}

//

function storageFileFromDirPath( storageDirPath )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let storageFilePath = null;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );

  storageDirPath = self.storageDirPathGet( storageDirPath );

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

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );

  let storageFilePath;
  if( self.storageFilePath )
  {
    storageFilePath = self._storageFilePathGet( storageDirPath );
  }
  else
  {
    storageDirPath = self.storageDirPathGet( storageDirPath );
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
    () => 'Directory for storage file does not exist ' + _.strQuote( storageFilePath )
  );

  return null;
}

//

function storageFilePathToSaveGet( storageDirPath )
{
  let self = this;
  let fileProvider = self.fileProvider;
  let storageFilePath = null;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );

  if( self.storageFilePath )
  {
    storageFilePath = self._storageFilePathGet( storageDirPath );
  }
  else
  {
    storageFilePath = self.storageFileFromDirPath( storageDirPath );
    // storageFilePath = fileProvider.path.s.join( storageDirPath , self.storageFileName );
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

function storageLoaded( storage, op )
{
  let self = this;
  let fileProvider = self.fileProvider;

  _.sure( self.storageIs( storage ), () => 'Strange storage : ' + _.toStrShort( storage ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.strIs( op.storageFilePath ) );

  if( self.loadedStorages !== undefined )
  {
    _.assert( _.arrayIs( self.loadedStorages ), () => 'expects {-self.loadedStorages-}, but got ' + _.strTypeOf( self.loadedStorages ) );
    self.loadedStorages.push({ filePath : op.storageFilePath });
  }

  if( self.storage !== undefined )
  self.storage = _.mapExtend( self.storage, storage );

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
  /* loadedStorages : _.define.own( [] ), */
  /* opened : 0, */
}

let Statics =
{
}

let Forbids =
{
  storageFor : 'storageFor',
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

  _storageFileLoad : _storageFileLoad,
  _storageLoad : _storageLoad,
  storageLoad : storageLoad,

  storageDirPathGet : storageDirPathGet,
  storageFileFromDirPath : storageFileFromDirPath,
  _storageFilePathGet : _storageFilePathGet,
  storageFilePathToLoadGet : storageFilePathToLoadGet,
  storageFilePathToSaveGet : storageFilePathToSaveGet,

  storageIs : storageIs,
  storageLoaded : storageLoaded,
  storageToSave : storageToSave,

  //

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
