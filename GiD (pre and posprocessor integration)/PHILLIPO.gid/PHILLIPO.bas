
{
    "title": "PHILLIPO: arquivo de entrada",
    "type": "plane_strain",
    "materials":[
*loop materials
        ["*Matprop(0)", *Matprop(1), *Matprop(2)], 
*end
        null
    ],
    "nodes":[
*loop nodes
*format "%e,%e"
        [*NodesCoord],
*end
        null
    ],
    "elements":{
        "linear":{
*set elems(triangles)
            "triangles":[
*loop elems
*format "%i%i%i,%i,%i"
                [*ElemsNum, *ElemsMat, *ElemsConec],
*end
                null
            ]       
        }
    },
    "constraints":{  
        "displacements":[
*Set Cond Constraint_displacement_line *nodes 
*loop nodes *OnlyInCond
            [*NodesNum, *cond(1), *cond(2), *cond(3)],
*end nodes
*Set Cond Constraint_displacement_surface *nodes 
*loop nodes *OnlyInCond
            [*NodesNum, *cond(1), *cond(2), *cond(3)],
*end nodes
*Set Cond Constraint_displacement_point *nodes
*loop nodes *OnlyInCond
            [*NodesNum, *cond(1), *cond(2), *cond(3)],
*end nodes
            null
        ],
        "forces_nodes":[
*Set Cond Constraint_force_point *nodes 
*loop nodes *OnlyInCond
            [*NodesNum, *cond(1), *cond(2), *cond(3)],
*end nodes
            null
        ]
    }
}

