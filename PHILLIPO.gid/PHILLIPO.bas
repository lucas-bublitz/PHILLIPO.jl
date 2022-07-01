
{
    "title": "PHILLIPO: arquivo de entrada",
    "type": "EPD",
    "materials":[
*loop materials
        [*MatNum, "*Matprop(0)", *Matprop(1), *Matprop(2)],
*end
    ],
    "nodes":[
*loop nodes
        [*NodesNum, *NodesCoord]
*end
       
    ],
}


NODES LIST


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
