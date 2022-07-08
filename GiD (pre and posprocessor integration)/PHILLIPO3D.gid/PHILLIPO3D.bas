
{
    "title": "PHILLIPO: arquivo de entrada",
    "type": "3D",
    "materials":[
*loop materials
        ["*Matprop(0)", *Matprop(1), *Matprop(2)], 
*end
        null
    ],
    "nodes":[
*loop nodes
*format "%e,%e,%e"
        [*NodesCoord],
*end
        null
    ],
    "elements":{
        "linear":{
*set elems(tetrahedra)
            "tetrahedrons":[
*loop elems
*format "%i%i%i,%i,%i,%i"
                [*ElemsNum, *ElemsMat, *ElemsConec],
*end
                null
            ]       
        }
    },
    "constraints":{  
        "displacements":[
*Set Cond Constraint_displacement *nodes 
*loop nodes *OnlyInCond
            [*NodesNum, *cond(1), *cond(2), *cond(3)],
*end nodes
            null
        ],
        "forces":[
*Set Cond Constraint_force *nodes 
*loop nodes *OnlyInCond
            [*NodesNum, *cond(1), *cond(2), *cond(3)],
*end nodes
            null
        ]
    }
}

