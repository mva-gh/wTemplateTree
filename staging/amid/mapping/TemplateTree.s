( function _TemplateTree_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof wBase === 'undefined' )
  try
  {
    require( '../include/BackTools.s' );
  }
  catch( err )
  {
  }

  if( typeof wBase === 'undefined' )
  try
  {
    require( '../include/wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  if( !wTools.FileProvider  )
  try
  {
    require( '../include/amid/file/FileMid.s' );
  }
  catch( err )
  {
    require( 'wFiles' );
  }

}

var _ = wTools;
var Parent = null;
var Self = function wTemplateTree( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'TemplateTree';

// --
// inter
// --

function init( o )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.instanceInit( self );

  if( o )
  self.copy( o );

  if( self.constructor === Self )
  Object.preventExtensions( self );

}

// --
// resolve
// --

function resolve( src )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var result = self._resolveEnter( src,'' );

  if( result instanceof self.ErrorQuerying )
  {
    debugger;
    throw _.err( result );
  }

  return result;
}

//

function resolveTry( src )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var result = self._resolveEnter( src,'' );

  if( result instanceof self.ErrorQuerying )
  return;

  return result;
}

//

function _resolveEnter( src,query )
{
  var self = this;
  var l = self.current.length;
  var node,path;

  _.assert( arguments.length === 2 );

  if( query === '' )
  {
    _.assert( l === 0 );
    node = self.tree;
    path = self.upSymbol;
  }
  else
  {
    node = src;
    path = self.current[ self.current.length-1 ].path;
  }

  var entered = self._enter( node,[ query ],path,0 );
  if( entered instanceof self.ErrorQuerying )
  {
    debugger;
    return entered;
  }

  var result = self._resolveEntered( src );

  self._leave( node );
  _.assert( self.current.length === l );

  return result;
}

//

function _resolveEntered( src )
{
  var self = this;

  _.assert( arguments.length === 1 );

  if( !self.shouldInvestigate( src ) )
  return src;

  if( _.strIs( src ) )
  return self._resolveString( src );

  if( _.regexpIs( src ) )
  return self._resolveRegexp( src );

  if( _.mapIs( src ) )
  return self._resolveMap( src );

  if( _.arrayLike( src ) )
  return self._resolveArray( src );

  throw _.err( 'repalce : unexpected type of src',_.strTypeOf( src ) );
}

//

function _resolveString( src )
{
  var self = this;
  var r;
  var result = '';

  var optionsForExtract =
  {
    prefix : self.prefixSymbol,
    postfix : self.postfixSymbol,
    onStrip : function( src ){ return [ src ]; },
  }

  var strips = _.strExtractStereoStrips.call( optionsForExtract,src );

  if( src === 'installer' )
  debugger;

  /* */

  for( var s = 0 ; s < strips.length ; s++ )
  {

    var strip = strips[ s ];

    if( _.strIs( strip ) )
    {
      r = strip;
    }
    else
    {
      r = self._queryEntered( strip[ 0 ] );
    }

    if( r instanceof self.ErrorQuerying )
    {
      r = _.err( r,'\ncant resolve :',src );
      return r;
    }

    if( result )
    {
      if( _.regexpIs( result ) )
      result = result.source;
      if( _.regexpIs( r ) )
      r = r.source;

      if( !_.strIs( result ) && self.onStrFrom )
      result = self.onStrFrom( result );

      _.assert( _.strIs( result ) );
      _.assert( _.strIs( r ) );
      result += r;
    }
    else
    {
      result = r;
    }

  }

  return result;
}

//

function _resolveRegexp( src )
{
  var self = this;

  _.assert( _.regexpIs( src ) );

  var source = src.source;
  source = self._resolveString( source );

  if( source instanceof self.ErrorQuerying )
  return source;

  if( source === src.source )
  return src;

  src = new RegExp( source,src.flags );

  return src;
}

//

function _resolveMap( src )
{
  var self = this;
  var result = Object.create( null );

  for( var s in src )
  {
    result[ s ] = self._resolveEnter( src[ s ],s );
    if( result[ s ] instanceof self.ErrorQuerying )
    {
      return result[ s ];
    }
  }

  return result;
}

//

function _resolveArray( src )
{
  var self = this;
  var result = new src.constructor( src.length );

  for( var s = 0 ; s < src.length ; s++ )
  {
    result[ s ] = self._resolveEnter( src[ s ],s );
    if( result[ s ] instanceof self.ErrorQuerying )
    {
      return result[ s ];
    }
  }

  return result;
}

// --
// query
// --

function query( query )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var result = self._queryEntering( query );
  if( result instanceof self.ErrorQuerying )
  {
    debugger;
    throw _.err( result,'\nquery :',query );
  }

  return result;
}

//

function queryTry( query )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var result = self._queryEntering( query );
  if( result instanceof self.ErrorQuerying )
  return;

  return result;
}

//

function _querySplit( query )
{
  var self = this;

  _.assert( _.strIs( query ) || _.arrayIs( query ) );
  _.assert( arguments.length === 1 );

  if( _.strIs( query ) )
  {

    /* query = query.split( self.upSymbol ); */

    query = _.strSplit
    ({
      src : query,
      delimeter : [ self.upSymbol,self.downSymbol ],
      preservingDelimeters : 1,
    });

    if( query[ 0 ] !== self.downSymbol && query[ 0 ] !== self.upSymbol )
    query.unshift( self.upSymbol );

  }

  return query;
}

//

function _queryEntering( query )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( !self.current.length );

  query = self._querySplit( query );

  //self._enter( self.tree,query,self.upSymbol,1 );
  self._enter( self.tree,query,'',1 );

  var result = self._queryEntered( query );

  self._leave( self.tree );
  _.assert( self.current.length === 0 );

  return result;
}

//

function _queryEntered( query )
{
  var self = this;

  _.assert( _.strIs( query ) || _.arrayIs( query ) );
  _.assert( arguments.length === 1 );

  if( _.strIs( query ) )
  {
    query = self._querySplit( query );
  }

  var result = self._queryAct( self.tree,query );

  return result;
}

//

function _queryAct( here,query )
{

  _.assert( arguments.length === 2 );
  _.assert( query.length > 0 );
  // _.assert( query[ 0 ] === self.upSymbol || query[ 0 ] === self.downSymbol );

  var result;
  var self = this;
  var path = self.current[ self.current.length-1 ].path;
  var queryOriginal = query;
  var newQuery;

  /* clear from up symbol */

  if( query[ 0 ] === self.upSymbol )
  query.splice( 0,1 );

  /* clear from down symbol or select */

  if( query[ 0 ] === self.downSymbol )
  {
    for( var q = 0 ; q < query.length ; q++ )
    if( query[ q ] !== self.downSymbol )
    break;
    query.splice( 0,q );
    if( self.current.length >= q )
    result = self.current[ self.current.length-q ].node;
    newQuery = query.slice();
  }
  else
  {
    result = here[ query[ 0 ] ];
    newQuery = query.slice( 1 );
  }

  /* */

  if( result === undefined )
  return self._errorQuerying({ at : path, query : queryOriginal.join( self.upSymbol ) });

  /* */

  var current = result;
  var entered = self._enter( current,query,path,0 );
  if( entered instanceof self.ErrorQuerying )
  return self._errorQuerying({ reason : 'dead cycle', at : path, query : queryOriginal.join( self.upSymbol ) });

  /* */

  if( newQuery.length )
  {
    if( _.strIs( result ) )
    result = self._resolveEntered( result );
    if( result !== undefined )
    result = self._queryAct( result,newQuery );
  }
  else
  {
    result = self._resolveEntered( result );
  }

  /* */

  self._leave( current );

  if( result === undefined )
  return self._errorQuerying({ at : path, query : query.join( self.upSymbol ) });

  return result;
}

// --
// tracker
// --

function _entryGet( entry )
{
  var self = this;

  var result = _.entityFilter( self.current,entry );

  return result;
}

//

function _enter( node,query,path,throwing )
{
  var self = this;

  _.assert( arguments.length === 4 );
  _.assert( _.arrayIs( query ) );

  var newPath;

  if( path === '' )
  newPath = '/'
  else if( path === '/' )
  newPath = path + query[ 0 ];
  else
  newPath = path + query[ 0 ] + query[ 1 ];

  // var newPath = path !== self.upSymbol ? path + query[ 0 ] + query[ 1 ] : path + query[ 0 ]; debugger;
  // var newPath = path + query[ 0 ] + query[ 1 ]; debugger;

  var d = {};
  d.node = node;
  d.path = newPath;
  d.query = query.join( '' );
  //d.query = query.join( self.upSymbol );

  if( query )
  if( self._entryGet({ query : d.query, node : node }).length )
  {
    var err = self._errorQuerying({ reason : 'dead cycle', at : newPath, query : d.query });;
    if( throwing )
    throw err;
    else
    return err;
  }

  self.current.push( d );

  return d;
}

//

function _leave( node )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var d = self.current.pop();

  _.assert( d.node === node );

  return d;
}

// --
// etc
// --

function ErrorQuerying( o )
{
  _.mapExtend( this,o );
  //self.stack = _.diagnosticStack();
}

ErrorQuerying.prototype = Object.create( Error.prototype );
ErrorQuerying.prototype.constructor = ErrorQuerying;
ErrorQuerying.prototype.name = 'x';

//

function _errorQuerying( o )
{
  var err = new ErrorQuerying( o );
  err = _.err( err );
  _.assert( err instanceof Error );
  _.assert( err instanceof ErrorQuerying );
  _.assert( err.stack );
  return err;
}

//

function shouldInvestigate( src )
{
  var self = this;

  if( _.strIs( src ) )
  return self.investigatingString;

  if( _.mapIs( src ) )
  return self.investigatingMap;

  if( _.regexpIs( src ) )
  return self.investigatingRegexp;

  if( _.arrayLike( src ) )
  return self.investigatingArrayLike;

  return false;
}

// --
// shortcuts
// --

function resolveAndAssign( src )
{
  var self = this;

  if( src !== undefined )
  self.tree = src;

  self.tree = self.resolve( self.tree );

  return self.tree;
}

// --
// relationships
// --

var Composes =
{

  investigatingString : true,
  investigatingMap : true,
  investigatingRegexp : true,
  investigatingArrayLike : true,

  current : [],

  prefixSymbol : '{{',
  postfixSymbol : '}}',
  downSymbol : '^',
  upSymbol : '/',

  onStrFrom : null,

}

var Associates =
{
  tree : null,
}

var Restricts =
{
}

var Statics =
{
  ErrorQuerying : ErrorQuerying,
}

// --
// proto
// --

var Proto =
{

  init : init,


  // resolve

  resolve : resolve,
  resolveTry : resolveTry,
  _resolveEnter : _resolveEnter,
  _resolveEntered : _resolveEntered,
  _resolveString : _resolveString,
  _resolveMap : _resolveMap,
  _resolveArray : _resolveArray,
  _resolveRegexp : _resolveRegexp,


  // query

  query : query,
  queryTry : queryTry,
  _querySplit : _querySplit,
  _queryEntering : _queryEntering,
  _queryEntered : _queryEntered,
  _queryAct : _queryAct,


  // tracker

  _entryGet : _entryGet,
  _enter : _enter,
  _leave : _leave,


  // etc

  _errorQuerying : _errorQuerying,
  shouldInvestigate : shouldInvestigate,


  // shortcuts

  resolveAndAssign : resolveAndAssign,


  // relationships

  constructor : Self,
  Composes : Composes,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

// define

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

wCopyable.mixin( Self );

wTools[ Self.nameShort ] = _global_[ Self.name ] = Self;

})();
