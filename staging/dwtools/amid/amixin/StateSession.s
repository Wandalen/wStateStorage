( function _StateSession_s_() {

'use strict';

/**
  @module Tools/mid/StateSession - Mixin to add persistent session storing functionality to a class. StateSession extends StateStorage. These modules solve the common problem to persistently store the state( session ) of an object. Them let save the state in a specific moment ( for example on process exit ) and to restore the state later ( for example on process start ). Use the module to be more cross-platform, don't repeat yourself and forget about details of implementation you don't worry.
*/

/**
 * @file files/StateSession.s.
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
  _.include( 'wStateStorage' );

}

//

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wStateSession( o )
{
  _.assert( arguments.length === 0 || arguments.length === 1, 'expects single argument' );
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'StateSession';

// --
//
// --

function sessionPrepare()
{
  let self = this;
  let exists = true;

  _.assert( self.opened !== undefined );
  _.assert( !self.opened );
  _.assert( arguments.length === 0 );

  if( !self.opened )
  {
    if( !self.storageLoad() )
    {
      exists = false;
    }
  }

  // debugger;
  // self.storageSave();
  self.opened = 1;

  return exists;
}

//

function sessionOpen()
{
  let self = this;

  if( self.opened )
  return self;

  _.assert( self.opened !== undefined );
  _.assert( !self.opened );
  _.assert( arguments.length === 0 );
  _.assert( _.strIsNotEmpty( self.storageFileName ), 'expects string field {-storageFileName-}' );

  if( !self.storageLoad() )
  throw _.errBriefly
  (
    'Cant open a session for ' + _.strQuote( self.storageFileName ) + '.\n' +
    'Looked ' + _.strQuote( self.storageDirPathGet() ) + '.'
  );

  // debugger;
  // _.sure( self.loadedStorages.length === 1 );

  self.opened = 1;
  return self;
}

//

function sessionClose()
{
  let self = this;
  _.assert( self.opened !== undefined );
  _.assert( arguments.length === 0 );
  if( !self.opened )
  return;
  self.sessionSave();
  self.opened = 0;
  if( self.storageFilePath !== undefined )
  self.storageFilePath = null;
  if( self.loadedStorages )
  self.loadedStorages.splice( 0 );
  return self;
}

//

function sessionSave()
{
  let self = this;
  _.assert( self.opened !== undefined );
  _.assert( !!self.opened );
  _.assert( arguments.length === 0 );
  self.storageSave();
  return self;
}

// --
//
// --

let Composes =
{
  /* storageFileName : '.storage', */
  /* storageFilePath : null, */
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
}

let Accessors =
{
}

// --
// declare
// --

let Supplement =
{

  sessionPrepare : sessionPrepare,
  sessionOpen : sessionOpen,
  sessionClose : sessionClose,
  sessionSave : sessionSave,

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
