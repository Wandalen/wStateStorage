
let _ = require( 'wTools' );
require( 'wFiles' );
require( 'wstatestorage' );

//

let Self = function wSample( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

//

function init( o )
{
  let sample = this;
  _.instanceInit( sample );
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
  storageFileName : '.sample.config.json',
  fileProvider : _.define.common( _.fileProvider ),
}

//

let Extend =
{

  init : init,
  storageLoaded : storageLoaded,
  storageToSave : storageToSave,

  Associates : Associates,

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
