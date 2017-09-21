
if( typeof module !== 'undefined' )
require( 'wtemplatetree' );

var tree = { 'a' : 'a', b : [ 1,2,3 ], c : { c1 : [ 1,2,3 ], c2 : [ 11,22,33 ] }, d : '{{^^a}}' }
var templateTree = new wTemplateTree();
templateTree.tree = tree;

var b1 = templateTree.query( 'b/1' );
var d = templateTree.query( 'd' );

console.log( 'b1 :',b1 );
// b1 : 2
console.log( 'd :',d );
// d : a
