PHILLIPO: ARQUIVO DE ENTRADA

PROBLEM DATA



MATERIALS
*loop materials
 *MatNum 
*end

NODES LIST
*loop nodes
 *NodesNum *NodesCoord
*end


*if(nelem(triangle)>0)
ELEMENTS triangle linear
*set elems(triangle)
*loop elems
*if(IsQuadratic(int)==0)
 *ElemsNum *ElemsConec *ElemsMat
*end 
*end
*end

*if(nelem(quadrilateral)>0)
ELEMENTS quadrilateral linear
*set elems(quadrilateral)
*loop elems
*if(IsQuadratic(int)==0)
 *ElemsNum *ElemsConec *ElemsMat
*end 
*end
*end