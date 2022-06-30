PHILLIPO: ARQUIVO DE ENTRADA

PROBLEM DATA

MATERIALS

*loop materials
*format "%4i%13.5e"
*set var PROP1(real)=Operation(MatProp(Density, real))
*MatNum *PROP1
*end

NODES LIST
*loop nodes
*format "%5i%14.5e%14.5e%14.5e"
*NodesNum *NodesCoord
*end

ELEMENTS
*set elems(all)
*loop elems
*ElemsNum *ElemsConec *ElemsMat 
*end

