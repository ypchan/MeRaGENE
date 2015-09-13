#!/usr/bin/env nextflow

params.unique
params.faa
params.out
params.cov

PYTHON="$baseDir/../vendor/python/bin/python"

process createOverview {
   
   cpus 2

   memory '4 GB'

   input:
   params.unique
   params.faa
   params.out
   params.cov

   output:
   val params.out + '/overview.txt' into over

   """
   #!/bin/sh
   $PYTHON $baseDir/create_overview.py -u ${params.unique}  -faa ${params.faa} -o ${params.out}  -c ${params.cov.replaceAll(',',' ')} 
   """
}


process linkSearch {
   
   cpus 2

   memory '4 GB'

   input: 
   val x from over
   params.out

   output:
   val params.out into inputF 

   """
   #!/bin/sh
   $PYTHON $baseDir/link_search.py -o ${x} -out ${params.out} 
   """
}


process folderToPubmed {
   
   cpus 2

   memory '4 GB'

   input:
   val inp from inputF
   params.out

   output:
   val params.out + '/all.pubHits'  into pub
   val params.out + '/overview.txt' into over2

   """
   #!/bin/sh
   sh $baseDir/FolderToPubmed.sh ${inp} ${params.out}  $baseDir/UrltoPubmedID.sh
   """
}


process linkAssignment {
 
   cpus 2
 
   memory '6 GB'

   input:
   val x from over2
   val p from pub

   """
   #!/bin/sh
   $PYTHON $baseDir/link_assignment.py -o ${x} -pub ${p} 
   """
}