
let _ = require( 'wTools' );
require( 'wFiles' );
require( 'wstatestorage' );

//

function wSample( o )
{
  return _.workpiece.construct( Self, this, arguments );
}
let Self = wSample;

//

function init( o )
{
  let sample = this;
  _.workpiece.initFields( sample );
}

//

function storageLoaded( storage, op )
{
  let self = this;
  let result = _.StateStorage.prototype.storageLoaded.call( self, storage, op );

  self.random = storage.random;

  return result;
}

//

function storageToSave( op )
{
  let self = this;

  let storage = { random : self.random };

  return storage;
}

//

let Associates =
{
  storageFileName : _.path.join( __dirname, '.sample.config.json' ), // strange
  fileProvider : _.define.common( _.fileProvider ),
}

//

let Extend =
{

  init,
  storageLoaded,
  storageToSave,

  Associates,

}

//

_.classDeclare
({
  cls : Self,
  extend : Extend,
});

_.StateStorage.mixin( Self );

//

let sample = new Self();
sample.storageLoad();
if( !sample.random )
sample.random = Math.random();
sample.storageSave();
console.log( 'sample.random', sample.storageFilePathToLoadGet(), sample.random );

_.fileProvider.filesDelete( _.path.join( __dirname, '.sample.config.json' ) );
