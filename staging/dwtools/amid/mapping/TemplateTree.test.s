( function _TemplateTree_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  // if( typeof wBase === 'undefined' )
  try
  {
    require( '../../Base.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  _.include( 'wTesting' );
  require( './TemplateTree.s' );

}

//

var _ = wTools;
var Parent = wTools.Tester;
var sourceFilePath = _.diagnosticLocation().full; // typeof module !== 'undefined' ? __filename : document.scripts[ document.scripts.length-1 ].src;

//

var _ = wTools;
var tree =
{
  atomic1 : 'a1',
  atomic2 : 2,
  branch1 : { a : 1, b : 'b', c : /xx/, d : '{atomic1}', e : '{atomic2}', f : '{branch2.0}', g :'{branch2.5}' },
  branch2 : [ 11,'bb',/yy/,'{atomic1}','{atomic2}','{branch1.a}','{branch1.f}' ],
  branch3 : [ 'a{atomic1}c','a{branch1.b}c','a{branch3.1}c','x{branch3.0}y{branch3.1}{branch3.2}z','{branch3.0}x{branch3.1}y{branch3.2}' ],

  relative : [ 'a','{^^.0}','0{^^.1}0' ],

  regexp : [ /b/,/a{regexp.0}/,/{regexp.1}c/,/{atomic1}x{regexp.0}y{regexp.2}z/g ],

  error : [ '{error.a}','{error2.0}','{^^.c}','{error.3}' ]

}

// --
// test
// --

function query( test )
{
  var self = this;
  var template = new wTemplateTree({ tree : tree, prefixSymbol : '{', postfixSymbol : '}', upSymbol : '.' });

  /* */

  var got = template.query( 'atomic1' );
  var expected = 'a1';
  test.identical( got,expected );

  var got = template.query( 'atomic2' );
  var expected = 2;
  test.identical( got,expected );

  /* */

  var got = template.query( 'branch1.a' );
  var expected = 1;
  test.identical( got,expected );

  var got = template.query( 'branch1.b' );
  var expected = 'b';
  test.identical( got,expected );

  var got = template.query( 'branch1.c' );
  var expected = /xx/;
  test.identical( got,expected );

  var got = template.query( 'branch1.d' );
  var expected = 'a1';
  test.identical( got,expected );

  var got = template.query( 'branch1.e' );
  var expected = 2;
  test.identical( got,expected );

  var got = template.query( 'branch1.f' );
  var expected = 11;
  test.identical( got,expected );

  var got = template.query( 'branch1.g' );
  var expected = 1;
  test.identical( got,expected );

  /* */

  var got = template.query( 'branch2.0' );
  var expected = 11;
  test.identical( got,expected );

  var got = template.query( 'branch2.1' );
  var expected = 'bb';
  test.identical( got,expected );

  var got = template.query( 'branch2.2' );
  var expected = /yy/;
  test.identical( got,expected );

  var got = template.query( 'branch2.3' );
  var expected = 'a1';
  test.identical( got,expected );

  var got = template.query( 'branch2.4' );
  var expected = 2;
  test.identical( got,expected );

  var got = template.query( 'branch2.5' );
  var expected = 1;
  test.identical( got,expected );

  var got = template.query( 'branch2.6' );
  var expected = 11;
  test.identical( got,expected );

  /* */

  test.description = 'error';

  var got = template.queryTry( 'aa' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.queryTry( 'error.0' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.queryTry( 'error.1' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.queryTry( 'error.2' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.queryTry( 'error.3' );
  var expected = undefined;
  test.identical( got,expected );

}

//

function resolve( test )
{
  var self = this;
  var template = new wTemplateTree
  ({
    tree : tree,
    prefixSymbol : '{',
    postfixSymbol : '}',
    upSymbol : '.'
  });

  /* */

  test.description = 'simple cases';

  var got = template.resolve( 'atomic1' );
  var expected = 'atomic1';
  test.identical( got,expected );

  var got = template.resolve( '{atomic1}' );
  var expected = 'a1';
  test.identical( got,expected );

  var got = template.resolve( '{atomic2}' );
  var expected = 2;
  test.identical( got,expected );

  var got = template.resolve( 'a{atomic1}b' );
  var expected = 'aa1b';
  test.identical( got,expected );

  var got = template.resolve( '{atomic2}' );
  var expected = 2;
  test.identical( got,expected );

  /* */

  test.description = 'complex cases';

  var got = template.resolve( '{branch3.0}' );
  var expected = 'aa1c';
  test.identical( got,expected );

  var got = template.resolve( '{branch3.1}' );
  var expected = 'abc';
  test.identical( got,expected );

  var got = template.resolve( '{branch3.2}' );
  var expected = 'aabcc';
  test.identical( got,expected );

  var got = template.resolve( '0{branch3.3}0' );
  var expected = '0xaa1cyabcaabccz0';
  test.identical( got,expected );

  var got = template.resolve( '0{branch3.4}0' );
  var expected = '0aa1cxabcyaabcc0';
  test.identical( got,expected );

  /* */

  test.description = 'regexp cases';

  debugger;
  var got = template.resolve( '{regexp.0}' );
  var expected = /b/;
  test.identical( got,expected );
  debugger;

  var got = template.resolve( '{regexp.1}' );
  var expected = /ab/;
  test.identical( got,expected );

  var got = template.resolve( '{regexp.2}' );
  var expected = /abc/;
  test.identical( got,expected );

  var got = template.resolve( '{regexp.3}' );
  var expected = /a1xbyabcz/g;
  test.identical( got,expected );

  var got = template.resolve( /0{regexp.3}0/ );
  var expected = /0a1xbyabcz0/;
  test.identical( got,expected );

  /* */

  test.description = 'non-string';

  var got = template.resolve( [ '{atomic1}','{atomic2}' ] );
  var expected = [ 'a1',2 ];
  test.identical( got,expected );

  var got = template.resolve( { atomic1 : '{atomic1}', atomic2 : '{atomic2}' } );
  var expected = { atomic1 : 'a1', atomic2 : 2 };
  test.identical( got,expected );

  var got = template.resolve( '{branch2}' );
  var expected = [ 11,'bb',/yy/,'a1',2,1,11 ];
  test.identical( got,expected );

  /* */

  test.description = 'relative';

  debugger;
  var got = template.query( 'relative.1' );
  debugger;
  var got = template.resolve( '{relative.1}' );
  debugger;
  var expected = 'a';
  test.identical( got,expected );

  var got = template.resolve( '{relative.2}' );
  var expected = '0a0';
  test.identical( got,expected );

  /* */

  test.description = 'not throwing error';

  var got = template.resolveTry( '{aa}' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( 'aa{aa}aa' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( '{error.0}' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( '{error.1}' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( '{error.2}' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( '{error.3}' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( [ '{error.3}' ] );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( { a : '{error.3}' } );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( /{error.3}/ );
  var expected = undefined;
  test.identical( got,expected );

  /* */

  debugger;
  test.description = 'throwing error';
  if( Config.debug )
  {

    test.shouldThrowErrorSync( function()
    {
      template.resolve( '{aa}' );
    });

    test.shouldThrowErrorSync( function()
    {
      template.resolve( 'aa{aa}aa' );
    });

    test.shouldThrowErrorSync( function()
    {
      template.resolve( '{error.0}' );
    });

    test.shouldThrowErrorSync( function()
    {
      template.resolve( '{error.1}' );
    });

    test.shouldThrowErrorSync( function()
    {
      template.resolve( '{error.2}' );
    });

    test.shouldThrowErrorSync( function()
    {
      template.resolve( '{error.3}' );
    });

    test.shouldThrowErrorSync( function()
    {
      template.resolve( [ '{error.3}' ] );
    });

    test.shouldThrowErrorSync( function()
    {
      template.resolve( { a : '{error.3}' } );
    });

    test.shouldThrowErrorSync( function()
    {
      template.resolve( /{error.3}/ );
    });

  }

  debugger;
}

// var tree =
// {
//   atomic1 : 'a1',
//   atomic2 : 2,
//   branch1 : { a : 1, b : 'b', c : /xx/, d : '{atomic1}', e : '{atomic2}', f : '{branch2.0}', g :'{branch2.5}' },
//   branch2 : [ 11,'bb',/yy/,'{atomic1}','{atomic2}','{branch1.a}','{branch1.f}' ],
//   regexp : [ /b/,/a{regexp.0}/,/{regexp.1}c/,/{atomic1}x{regexp.0}y{regexp.2}z/g ],
// }

// --
// proto
// --

var Self =
{

  name : 'TemplateTree',
  sourceFilePath : sourceFilePath,
  verbosity : 1,

  tests :
  {

    query : query,
    resolve : resolve,

  },

};

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
