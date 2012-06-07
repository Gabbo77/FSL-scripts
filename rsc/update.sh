#!/bin/bash

#set -e

if [ $# -lt 1 ] ; then echo "Usage: update [32|64]" ; exit ; fi

if [ x$FSL_DIR = "x" ] ; then echo "FSL_DIR variable is not defined ! Exiting." ; exit 1 ; fi
if [ x$FREESURFER_HOME = "x" ] ; then echo "FREESURFER_HOME variable is not defined ! Exiting." ; exit 1 ; fi

cp -iv fsl/tbss_x/tbss_x $FSL_DIR/bin/tbss_x
cp -iv fs/trac-all $FREESURFER_HOME/bin/trac-all
cp -iv fsl/topup/b02b0.cnf $FSL_DIR/etc/flirtsch/b02b0.cnf
cp -iv fsl/MNI152*.nii.gz $FSL_DIR/data/standard/
cp -iv fsl/avg152T1_white_bin.nii.gz $FSL_DIR/data/standard/
cp -iv fsl/avg152T1_csf_bin.nii.gz $FSL_DIR/data/standard/
cp -iv scripts/featlib.tcl $FSL_DIR/tcl/featlib.tcl
#cp -iv scripts/fsl_sub_NOPOSIXLY.sh $FSL_DIR/bin/fsl_sub # patched for freesurfer 


if [ $1 -eq 64 ] ; then

  cp -iv fsl/topup/topup_blade $FSL_DIR/bin/topup
  cp -iv fsl/topup/applytopup_blade $FSL_DIR/bin/applytopup
  cp -iv fsl/tbss_x/swap_voxelwise_64 $FSL_DIR/bin/swap_voxelwise
  cp -iv fsl/tbss_x/swap_subjectwise_64 $FSL_DIR/bin/swap_subjectwise

fi

if [ $1 -eq 32 ] ; then

  cp -iv fsl/topup/topup_32 $FSL_DIR/bin/topup
  cp -iv fsl/topup/applytopup_32 $FSL_DIR/bin/applytopup
  cp -iv fsl/tbss_x/swap_voxelwise_32 $FSL_DIR/bin/swap_voxelwise
  cp -iv fsl/tbss_x/swap_subjectwise_32 $FSL_DIR/bin/swap_subjectwise

fi
chmod +x $FSL_DIR/bin/topup
chmod +x $FSL_DIR/bin/applytopup
chmod +x $FSL_DIR/bin/swap_voxelwise
chmod +x $FSL_DIR/bin/swap_subjectwise
chmod +x $FSL_DIR/bin/tbss_x
chmod +x $FREESURFER_HOME/bin/trac-all