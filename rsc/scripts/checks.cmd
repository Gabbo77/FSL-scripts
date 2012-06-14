############
# CHECK LOGS
############

# check recon-all
grep --color=always  "finished without error" ./logs/* | grep recon-all | grep -v recon-all_base | grep -v recon-all_long
grep --color=always  "finished without error" ./logs/* | grep recon-all_base
grep --color=always  "finished without error" ./logs/* | grep recon-all_long



# check tracula
grep --color=always  "finished without error" ./logs/* | grep trac-all-prep

c=1
for i in `find ./subj/FS_subj -name monitor -type f | sort` ; do
  i=$(dirname $i)
  if [ -f $i/xfms/eye.mat ] ; then
    echo "$c '$i' : finished"
  else
    echo "$c '$i' : unfinished"
  fi
  c=$[$c+1]
done
c=0

grep --color=always  "finished without error" ./logs/* | grep trac-all-paths



# check sge error-logs
greperror.sh logs/*.e*



# check BPX
subdir=bpx_topup_ec_bvecrot.bedpostX
c=1 ; for i in `find ./subj -name monitor -type f | grep /bpx/$subdir | sort` ; do
  i=$(dirname $i)
  if [ -f $i/xfms/eye.mat ] ; then
    echo "$c '$i' : finished."
  else
    echo "$c '$i' : UNFINISHED."
  fi
  c=$[$c+1]
done ; c=0



# check feat - dwi
subdir=unwarpDWI_y.feat
find ./subj -name report_log.html -type f | grep /fdt/$subdir | sort | xargs  -I {} greperror.sh {}



# check feat - bold
subdir=preprocBOLD_uw+y_st0_s0_hpfInf.feat
find ./subj -name report_log.html -type f | grep /bold/$subdir | sort | xargs  -I {} greperror.sh {}



# check VBM
subdir=vbm_nonflip
greperror.sh ./grp/vbm/$subdir/*/fslvbm*
greperror.sh ./grp/vbm/$subdir/stats*/*/*/*.generate*



# check TBSS
subdir=tbss_nonflip_topup_ec_bvecrot
find ./grp/tbss/$subdir/*/ -name tbss_?_*  | sort | xargs -I {} greperror.sh {}
greperror.sh ./grp/tbss/$subdir/stats*/*/*/*.generate* 



# check dualreg
subdir=ica_50_allICs_n2000
greperror.sh ./grp/dualreg/$subdir/scripts+logs/*





##############
# CHECK IMAGES
##############

################################
# check denoise masks (mni bold)
################################
file=filtered_func_data_longt_mni2.nii.gz ; subdir=bold/SESSA_uw+y_st0_s0_hpfInf.feat ; out=chk/MNI_bold_merged

mkdir -p $(dirname $out)
files=$(find ./subj -name $file | grep /$subdir/reg_standard/ | sort)
c=1; for i in $files ; do echo "$(zeropad $c 3) $i" ; c=$[$c+1] ; done ; c=0 
extract_merge.sh $out 0 "$files"
cmd="fslview ${out} $FSL_DIR/data/standard/avg152T1_csf_bin.nii.gz -l "Blue" -t 0.5 $FSL_DIR/data/standard/avg152T1_white_bin.nii.gz -l "Yellow" -t 0.5" 
echo $cmd | tee ${out}.cmd ; chmod +x ${out}.cmd ; $cmd


######################################
# check denoise masks (mni bold) - alt
######################################
file=filtered_func_data_mni2.nii.gz ; subdir=bold/SESSA_uw+y_st0_s0_hpfInf.feat ; out=MNI_bold_
subj=$(find ./subj -mindepth 1 -maxdepth 1 -type d | grep -v FS_ | sort)
sess="a b c d e"

mkdir -p $(dirname $out) ; imrm ${out}tmp_????
f_WM=""; f_CSF=""; f_WB=""; f_bold=""
c=1 ; for i in $subj ; do
  for j in $sess ; do 
    if [ -f $i/$j/$subdir/reg_standard/$file -a -d $i/$j/$subdir/reg_standard/noise ] ; then
      echo "$(zeropad $c 3) $i $j : found."
      f_WM=$f_WM" "$i/$j/$subdir/reg_standard/noise/MNI_WM
      f_CSF=$f_CSF" "$i/$j/$subdir/reg_standard/noise/MNI_CSF
      f_WB=$f_WB" "$i/$j/$subdir/reg_standard/noise/EF_WB
      extract_merge.sh ${out}tmp_$(zeropad $c 4) 0 "$i/$j/$subdir/reg_standard/$file"
      f_bold=$f_bold" "${out}tmp_$(zeropad $c 4)
      c=$[$c+1]
    else
      echo "    $i $j : not found."
    fi
  done
done ; c=0
fslmerge -t ${out}WM_merged  $f_WM 2>/dev/null
fslmerge -t ${out}CSF_merged  $f_CSF 2>/dev/null
fslmerge -t ${out}WB_merged  $f_WB 2>/dev/null
fslmerge -t ${out}merged $f_bold 2>/dev/null
imrm ${out}tmp_????
cmd="fslview ${out}merged ${out}WB_merged -t 0 ${out}CSF_merged -l "Blue" -t 0.5 ${out}WM_merged -l "Yellow" -t 0.5"
echo $cmd | tee ${out}.cmd ; chmod +x ${out}.cmd ; $cmd


###################################
# check denoise masks (native bold)
###################################
file=example_func.nii.gz ; subdir=bold/SESSA_uw+y_st0_s0_hpfInf.feat ; out=chk/EF_bold_
subj=$(find ./subj -mindepth 1 -maxdepth 1 -type d | grep -v FS_ | sort)
sess="a b c d e"

mkdir -p $(dirname $out) ; imrm ${out}tmp_????
f_WM=""; f_CSF=""; f_WB=""; f_bold=""
c=1 ; for i in $subj ; do
  for j in $sess ; do 
    if [ -f $i/$j/$subdir/$file -a -d $i/$j/$subdir/noise ] ; then
      echo "$(zeropad $c 3) $i $j : found."
      f_WM=$f_WM" "$i/$j/$subdir/noise/EF_WM
      f_CSF=$f_CSF" "$i/$j/$subdir/noise/EF_CSF
      f_WB=$f_WB" "$i/$j/$subdir/noise/EF_WB
      f_bold=$f_bold" "$i/$j/$subdir/$file
      c=$[$c+1]
    else
      echo "    $i $j : not found."
    fi
  done
done ; c=0
fslmerge -t ${out}WM_merged  $f_WM 2>/dev/null
fslmerge -t ${out}CSF_merged  $f_CSF 2>/dev/null
fslmerge -t ${out}WB_merged  $f_WB 2>/dev/null
fslmerge -t ${out}merged $f_bold 2>/dev/null
imrm ${out}tmp_????
cmd="fslview ${out}merged ${out}WB_merged -t 0 ${out}CSF_merged -l "Blue" -t 0.5 ${out}WM_merged -l "Yellow" -t 0.5"
echo $cmd | tee ${out}.cmd ; chmod +x ${out}.cmd ; $cmd


############################
# check vbm brain extraction
############################
struc=*_t1_orig.nii.gz ; brain=*_t1_watershed_initbrain.nii.gz ; out=chk/vbm_
subj=$(find ./subj -mindepth 1 -maxdepth 1 -type d | grep -v FS_ | sort)
sess="a b c d e"

mkdir -p $(dirname $out) ; imrm ${out}tmp_????
f_brain=""; f_struc=""
c=1 ; for i in $subj ; do
  for j in $sess ; do 
    if [ -f $i/$j/vbm/$struc -a -f $i/$j/vbm/$brain ] ; then
      echo "$(zeropad $c 3) $i $j : found."
      f_brain=$f_brain" "$i/$j/vbm/$brain 
      f_struc=$f_struc" "$i/$j/vbm/$struc
      c=$[$c+1]
    else
      echo "    $i $j : not found."
    fi
  done
done ; c=0
fslmerge -t ${out}brain  $f_brain 2>/dev/null
fslmerge -t ${out}struc  $f_struc 2>/dev/null

cmd="fslview ${out}struc -t 0.5 ${out}brain -t 1"
echo $cmd | tee ${out}.cmd ; chmod +x ${out}.cmd ; $cmd


###################
# check bold unwarp
###################
file=bold/preprocBOLD_hpf100_s4_uw-y.feat/filtered_func_data.nii.gz ; file2=$(dirname $file)/unwarp/EF_UD_fmap_mag_brain.nii.gz ; out=chk/EF_bold_
subj=$(find ./subj -mindepth 1 -maxdepth 1 -type d | grep -v FS_ | sort)
sess="a b c d e"

mkdir -p $(dirname $out) ; imrm ${out}tmp_????
files=""; files2="";
c=1 ; for i in $subj ; do
  for j in $sess ; do 
    if [ -f $i/$j/$file -a -f $i/$j/$file2 ] ; then
      echo "$(zeropad $c 3) $i $j : found."
      extract_merge.sh ${out}tmp_$(zeropad $c 4) 0 "$i/$j/$file"
      files=$files" "${out}tmp_$(zeropad $c 4)
      #files=$files" "$i/$j/$file
      files2=$files2" "$i/$j/$file2
      c=$[$c+1]
    else
      echo "    $i $j : not found."
    fi
  done
done ; c=0
fslmerge -t ${out}merged $files 2>/dev/null
fslmerge -t ${out}magn_merged $files2 2>/dev/null
imrm ${out}tmp_????
cmd="fslview ${out}magn_merged -l "Blue-Lightblue" ${out}merged"
echo $cmd | tee ${out}.cmd ; chmod +x ${out}.cmd ; $cmd


##################
# check dwi unwarp
##################
file=fdt/unwarpDWI_y.feat/filtered_func_data.nii.gz ; file2=$(dirname $file)/unwarp/EF_UD_fmap_mag_brain.nii.gz ; out=chk/EF_dwi_
subj=$(find ./subj -mindepth 1 -maxdepth 1 -type d | grep -v FS_ | sort)
sess="a c e"

mkdir -p $(dirname $out) ; imrm ${out}tmp_????
files=""; files2="";
c=1 ; for i in $subj ; do
  for j in $sess ; do 
    if [ -f $i/$j/$file -a -f $i/$j/$file2 ] ; then
      echo "$(zeropad $c 3) $i $j : found."
      extract_merge.sh ${out}tmp_$(zeropad $c 4) 0 "$i/$j/$file"
      files=$files" "${out}tmp_$(zeropad $c 4)
      #files=$files" "$i/$j/$file
      files2=$files2" "$i/$j/$file2
      c=$[$c+1]
    else
      echo "    $i $j : not found."
    fi
  done
done ; c=0
fslmerge -t ${out}merged $files 2>/dev/null
fslmerge -t ${out}magn_merged $files2 2>/dev/null
imrm ${out}tmp_????
cmd="fslview ${out}magn_merged -l "Blue-Lightblue" ${out}merged"
echo $cmd | tee ${out}.cmd ; chmod +x ${out}.cmd ; $cmd


##########################
# check fmap & hpf'ed fmap
##########################
file=fm/fmap_rads_masked.nii.gz ; file2=fm/uphase_rad_filt.nii.gz ; out=chk/fmap_
subj=$(find ./subj -mindepth 1 -maxdepth 1 -type d | grep -v FS_ | sort)
sess="a b c d e"

mkdir -p $(dirname $out)
files=""; files2=""
c=1 ; for i in $subj ; do
  for j in $sess ; do 
    if [ -f $i/$j/$file -a -f $i/$j/$file2 ] ; then
      echo "$(zeropad $c 3) $i $j : found."
      files=$files" "$i/$j/$file
      files2=$files2" "$i/$j/$file2
      c=$[$c+1]
    else
      echo "    $i $j : not found."
    fi
  done
done ; c=0
fslmerge -t ${out}merged $files 2>/dev/null
fslmerge -t ${out}filt $files2 2>/dev/null
cmd="fslview ${out}filt ${out}merged"
echo $cmd | tee ${out}.cmd ; chmod +x ${out}.cmd ; $cmd


############################################
# check averaged MNI-bolds & hpf'ed MNI-fmap
############################################
file=bold/SESSA_uw+y_st0_s0_hpfInf.feat/reg_standard/filtered_func_data_mni2.nii.gz ; file2=fm/pseudoSWI_MNI.nii.gz ; out=chk/meanMNIbold_
subj=$(find ./subj -mindepth 1 -maxdepth 1 -type d | grep -v FS_ | sort)
sess="a b c d e"

mkdir -p $(dirname $out)
files=""; files2=""
c=1 ; for i in $subj ; do
  for j in $sess ; do 
    if [ -f $i/$j/$file -a -f $i/$j/$file2 ] ; then
      echo "$(zeropad $c 3) $i $j : found."
      cmd="fslmaths $i/$j/$file -Tmean ${out}tmp_$(zeropad $c 4)"
      echo "     $cmd" ; $cmd
      files=$files" "${out}tmp_$(zeropad $c 4)
      files2=$files2" "$i/$j/$file2
      c=$[$c+1]
    else
      echo "    $i $j : not found."
    fi
  done
done ; c=0
fslmerge -t ${out}merged $files 2>/dev/null
fslmerge -t ${out}filt $files2 2>/dev/null
imrm ${out}tmp_????
cmd="fslview ${out}filt ${out}merged"
echo $cmd | tee ${out}.cmd ; chmod +x ${out}.cmd ; $cmd


###########################################
# check FREESURFER's Talairach registration
###########################################
subj=$(find ./subj/FS_subj -mindepth 1 -maxdepth 1 -type d | grep -v '.long.' | sort)
SUBJECTS_DIR=./subj/FS_subj

paths="" ; c=1
for i in $subj ; do
    if [ -f ${i}/mri/transforms/talairach.auto.xfm ] ; then
      echo "$(zeropad $c 3) $i : found."
      paths=$paths" "${i}
      c=$[$c+1]
    else
      echo "    $i : not found."
    fi
    
  done

for i in $paths ; do
  tkregister2 --s $(basename $i) --fstal --surf
done


###############################################
# check FREESURFER's surfaces and segmentations
###############################################
subj=$(find ./subj/FS_subj -mindepth 1 -maxdepth 1 -type d | grep -v '.long.' | sort)
SUBJECTS_DIR=./subj/FS_subj

paths="" ; c=1
for i in $subj ; do
    if [ -f ${i}/mri/aparc+aseg.mgz  ] ; then
      echo "$(zeropad $c 3) $i : found."
      paths=$paths" "${i}
      c=$[$c+1]
    else
      echo "    $i : not found."
    fi
    
  done

for i in $paths ; do
  tkmedit $(basename $i) brainmask.mgz -aux T1.mgz -surfs -aseg &
  tksurfer $(basename $i) lh inflated
  read -p "press key..."
done



############
# check TBSS
############

statdirs=$(find ./grp/tbss/ -name "stats_*" -type d | sort)
out=chk/tbss.cmd

rm -f $out
for i in $statdirs ; do
  if [ -f $i/all_FA_skeletonised.nii.gz -a -f $i/all_FA.nii.gz ] ; then
    echo "$i : found."
    echo "fslview $i/all_FA.nii.gz -l \"Grayscale\" -t 1 $i/mean_FA_skeleton_mask.nii.gz -l \"Blue\" -t 1 $i/all_FA_skeletonised.nii.gz -l \"Red-Yellow\" -t 1"  >> $out
    if [ -f $i/all_F1_x_skeletonised.nii.gz -a -f $i/all_F2_x_skeletonised.nii.gz -a -f $i/all_FA.nii.gz ] ; then
      echo "fslview $i/all_FA.nii.gz -l \"Grayscale\" -t 1 $i/mean_FA_skeleton_mask.nii.gz -l \"Blue\" -t 1 $i/all_F2_x_skeletonised.nii.gz -l \"Red-Yellow\" -t 1 $i/all_F1_x_skeletonised.nii.gz -l \"Red-Yellow\" -t 1" >> $out
    fi
  else
    echo "$i : not found."
  fi
done

cat $out






