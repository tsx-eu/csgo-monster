// Created by Crowbar 0.68

$modelname "npc/tsx/zombie/zombie.mdl"

$bodygroup "studio"
{
	studio "zombie_ctm_fbi_reference.smd"
	studio "zombie_ctm_fbi_reference2.smd"
	studio "zombie_ctm_fbi_reference3.smd"
	studio "zombie_ctm_fbi_reference4.smd"
	studio "zombie_ctm_fbi_reference5.smd"
	studio "zombie_ctm_fbi_reference6.smd"
	studio "zombie_ctm_fbi_reference7.smd"
	studio "zombie_ctm_fbi_reference8.smd"
	studio "zombie_ctm_fbi_reference9.smd"
	studio "zombie_ctm_fbi_reference10.smd"
	studio "zombie_ctm_fbi_reference11.smd"
	studio "zombie_ctm_fbi_reference12.smd"
	studio "zombie_ctm_fbi_reference13.smd"
	studio "zombie_ctm_fbi_reference14.smd"
	studio "zombie_ctm_fbi_reference15.smd"
	studio "zombie_ctm_fbi_reference16.smd"
	studio "zombie_ctm_fbi_reference17.smd"
	studio "zombie_ctm_fbi_reference18.smd"
	studio "zombie_ctm_fbi_reference19.smd"
}


$surfaceprop "flesh"

$contents "solid"

$illumposition 0.133 -0.94 38.927

$opaque

$cdmaterials "models\npc\tsx\zombie\"
$cdmaterials ""

$cbox 0 0 0 0 0 0

$bbox -13.717 -20.027 -0.168 15.597 20.289 78.022

$definebone "Bip001" "" 0 1.756929 37.615288 0 -89.999927 0 0 0 0 0 0 0
$definebone "Bip001 Pelvis" "Bip001" 0 0 0 -89.999982 -89.999927 0 0 0 0 0 0 0
$definebone "Bip001 Spine" "Bip001 Pelvis" 5.267933 -0.013313 0.000007 -0.000057 0.045607 -0.000229 0 0 0 0 0 0
$definebone "Bip001 Neck" "Bip001 Spine" 20.513325 0.725222 0.000001 -0.000057 24.593927 0 0 0 0 0 0 0
$definebone "Bip001 Head" "Bip001 Neck" 2.642925 0 0 0.000057 -16.835108 0 0 0 0 0 0 0
$definebone "Bip001 Ponytail1" "Bip001 Head" 1.553886 1.814199 -0.000002 -0.000172 101.130206 -0.000172 0 0 0 0 0 0
$definebone "Bip001 L Clavicle" "Bip001 Spine" 17.118809 -0.000324 2.543092 -79.715042 -151.654419 -28.781164 0 0 0 0 0 0
$definebone "Bip001 L UpperArm" "Bip001 L Clavicle" 7.366349 0 0.000011 -1.577293 -1.81868 6.375872 0 0 0 0 0 0
$definebone "Bip001 L Forearm" "Bip001 L UpperArm" 11.129744 -0.000002 -0.000004 0.000002 -7.039588 -0.000004 0 0 0 0 0 0
$definebone "Bip001 L Hand" "Bip001 L Forearm" 12.924172 0 0.000008 2.022945 0 -89.954377 0 0 0 0 0 0
$definebone "Bip001 L Finger0" "Bip001 L Hand" 6.979836 0.406921 -0.00994 0.020567 26.814366 -0.040734 0 0 0 0 0 0
$definebone "Bip001 R Clavicle" "Bip001 Spine" 17.118816 -0.00031 -2.543091 79.715158 -151.655963 28.779613 0 0 0 0 0 0
$definebone "Bip001 R UpperArm" "Bip001 R Clavicle" 7.36635 0 0.000008 1.577298 -1.818683 -6.37588 0 0 0 0 0 0
$definebone "Bip001 R Forearm" "Bip001 R UpperArm" 11.129751 0.000001 -0.000008 0.000001 -7.039589 -0.000004 0 0 0 0 0 0
$definebone "Bip001 R Hand" "Bip001 R Forearm" 12.924163 -0.000001 0.000011 -2.022943 0 89.954377 0 0 0 0 0 0
$definebone "Bip001 R Finger0" "Bip001 R Hand" 6.979837 0.40691 0.009943 -0.02057 26.814372 0.040741 0 0 0 0 0 0
$definebone "Bip001 L Thigh" "Bip001 Pelvis" -0.000008 0.000008 4.580808 -2.639672 177.191062 175.795873 0 0 0 0 0 0
$definebone "Bip001 L Calf" "Bip001 L Thigh" 19.153725 0 0.000001 0 -7.873814 0 0 0 0 0 0 0
$definebone "Bip001 L Foot" "Bip001 L Calf" 13.825933 0.000001 0 -2.423384 4.87633 4.332364 0 0 0 0 0 0
$definebone "Bip001 L Toe0" "Bip001 L Foot" 4.534308 6.882616 -0.000001 0 89.999982 0 0 0 0 0 0 0
$definebone "Bip001 R Thigh" "Bip001 Pelvis" 0.000008 -0.000005 -4.580808 2.639822 177.191131 -175.795696 0 0 0 0 0 0
$definebone "Bip001 R Calf" "Bip001 R Thigh" 19.153727 0 0.000001 0 -7.873817 0 0 0 0 0 0 0
$definebone "Bip001 R Foot" "Bip001 R Calf" 13.825928 0 0 2.423383 4.876329 -4.332363 0 0 0 0 0 0
$definebone "Bip001 R Toe0" "Bip001 R Foot" 4.534307 6.882615 -0.000001 -0.000001 89.999982 0 0 0 0 0 0 0

$sectionframes 30 30

$weightlist body_top {
  "Bip001" 0
  
  "Bip001 Pelvis" 1
  "Bip001 Spine" 1
  "Bip001 Neck" 1
  "Bip001 Head" 1
  "Bip001 Ponytail1" 1
  "Bip001 L Clavicle" 1
  "Bip001 L UpperArm" 1
  "Bip001 L Forearm" 1
  "Bip001 L Hand" 1
  "Bip001 L Finger0" 1
  "Bip001 R Clavicle" 1
  "Bip001 R UpperArm" 1
  "Bip001 R Forearm" 1
  "Bip001 R Hand" 1
  "Bip001 R Finger0" 1
  
  "Bip001 L Thigh" 0
  "Bip001 L Calf" 0
  "Bip001 L Foot" 0
  "Bip001 L Toe0" 0
  "Bip001 R Thigh" 0
  "Bip001 R Calf" 0
  "Bip001 R Foot" 0
  "Bip001 R Toe0" 0
}

$weightlist body_top_left {
  "Bip001" 0
  
  "Bip001 Pelvis" 1
  "Bip001 Spine" 1
  "Bip001 Neck" 0
  "Bip001 Head" 0
  "Bip001 Ponytail1" 1
  
  "Bip001 L Clavicle" 1
  "Bip001 L UpperArm" 1
  "Bip001 L Forearm" 1
  "Bip001 L Hand" 1
  "Bip001 L Finger0" 1
  
  "Bip001 R Clavicle" 0
  "Bip001 R UpperArm" 0
  "Bip001 R Forearm" 0
  "Bip001 R Hand" 0
  "Bip001 R Finger0" 0
  
  "Bip001 L Thigh" 0
  "Bip001 L Calf" 0
  "Bip001 L Foot" 0
  "Bip001 L Toe0" 0
  "Bip001 R Thigh" 0
  "Bip001 R Calf" 0
  "Bip001 R Foot" 0
  "Bip001 R Toe0" 0
}

$weightlist body_top_right {
  "Bip001" 0
  
  "Bip001 Pelvis" 1
  "Bip001 Spine" 1
  "Bip001 Neck" 0
  "Bip001 Head" 0
  "Bip001 Ponytail1" 1
  
  "Bip001 L Clavicle" 0
  "Bip001 L UpperArm" 0
  "Bip001 L Forearm" 0
  "Bip001 L Hand" 0
  "Bip001 L Finger0" 0
  
  "Bip001 R Clavicle" 1
  "Bip001 R UpperArm" 1
  "Bip001 R Forearm" 1
  "Bip001 R Hand" 1
  "Bip001 R Finger0" 1
  
  "Bip001 L Thigh" 0
  "Bip001 L Calf" 0
  "Bip001 L Foot" 0
  "Bip001 L Toe0" 0
  "Bip001 R Thigh" 0
  "Bip001 R Calf" 0
  "Bip001 R Foot" 0
  "Bip001 R Toe0" 0
}
$weightlist body_bot {
  "Bip001" 0
  
  "Bip001 Pelvis" 0
  "Bip001 Spine" 0
  "Bip001 Neck" 0
  "Bip001 Head" 0
  "Bip001 Ponytail1" 0
  "Bip001 L Clavicle" 0
  "Bip001 L UpperArm" 0
  "Bip001 L Forearm" 0
  "Bip001 L Hand" 0
  "Bip001 L Finger0" 0
  "Bip001 R Clavicle" 0
  "Bip001 R UpperArm" 0
  "Bip001 R Forearm" 0
  "Bip001 R Hand" 0
  "Bip001 R Finger0" 0
  
  "Bip001 L Thigh" 1
  "Bip001 L Calf" 1
  "Bip001 L Foot" 1
  "Bip001 L Toe0" 1
  "Bip001 R Thigh" 1
  "Bip001 R Calf" 1
  "Bip001 R Foot" 1
  "Bip001 R Toe0" 1
}


$sequence "idle" {
	"zombie_anims\idle_lower.smd"
	fadein 1
	fadeout 0.5
	fps 30
	loop
}
$sequence "walk" {
	"zombie_anims\walk_lower.smd"
	fadein 0.5
	fadeout 0.5
	fps 28
	loop
}
$sequence "run" {
	"zombie_anims\run_lower.smd"
	fadein 0.25
	fadeout 0.5
	fps 35
	loop
}
$sequence "melee_L_uper" {
	"zombie_anims\Run_Shoot_KNIFE_LIGHT_R.smd"
	fadein 0.2
	fadeout 0.2
	fps 50
	weightlist "body_top_left"
}
$sequence "melee_R_uper" {
	"zombie_anims\Run_Shoot_KNIFE_LIGHT_L.smd"
	fadein 0.2
	fadeout 0.2
	fps 50
	weightlist "body_top_right"
}
$sequence "dead" {
	"zombie_anims\dead.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
}
$sequence "dead_loop" {
	"zombie_anims\dead_loop.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
}

$collisionjoints "zombie_physics.smd"
{
	$mass 0
	$inertia 10
	$damping 0.01
	$rotdamping 1.5
	$rootbone " "


	$jointconstrain "Bip001 R Thigh" x limit 0 0 0
	$jointconstrain "Bip001 R Thigh" y limit 0 0 0
	$jointconstrain "Bip001 R Thigh" z limit 0 0 0

	$jointconstrain "Bip001 R Calf" x limit 0 0 0
	$jointconstrain "Bip001 R Calf" y limit 0 0 0
	$jointconstrain "Bip001 R Calf" z limit 0 0 0

	$jointconstrain "Bip001 L Thigh" x limit 0 0 0
	$jointconstrain "Bip001 L Thigh" y limit 0 0 0
	$jointconstrain "Bip001 L Thigh" z limit 0 0 0

	$jointconstrain "Bip001 L Calf" x limit 0 0 0
	$jointconstrain "Bip001 L Calf" y limit 0 0 0
	$jointconstrain "Bip001 L Calf" z limit 0 0 0

	$jointconstrain "Bip001 L Foot" x limit 0 0 0
	$jointconstrain "Bip001 L Foot" y limit 0 0 0
	$jointconstrain "Bip001 L Foot" z limit 0 0 0

	$jointconstrain "Bip001 Spine" x limit 0 0 0
	$jointconstrain "Bip001 Spine" y limit 0 0 0
	$jointconstrain "Bip001 Spine" z limit 0 0 0

	$jointconstrain "Bip001 R UpperArm" x limit 0 0 0
	$jointconstrain "Bip001 R UpperArm" y limit 0 0 0
	$jointconstrain "Bip001 R UpperArm" z limit 0 0 0

	$jointconstrain "Bip001 R Forearm" x limit 0 0 0
	$jointconstrain "Bip001 R Forearm" y limit 0 0 0
	$jointconstrain "Bip001 R Forearm" z limit 0 0 0

	$jointconstrain "Bip001 L UpperArm" x limit 0 0 0
	$jointconstrain "Bip001 L UpperArm" y limit 0 0 0
	$jointconstrain "Bip001 L UpperArm" z limit 0 0 0

	$jointconstrain "Bip001 L Forearm" x limit 0 0 0
	$jointconstrain "Bip001 L Forearm" y limit 0 0 0
	$jointconstrain "Bip001 L Forearm" z limit 0 0 0

	$jointconstrain "Bip001 L Hand" x limit 0 0 0
	$jointconstrain "Bip001 L Hand" y limit 0 0 0
	$jointconstrain "Bip001 L Hand" z limit 0 0 0

	$jointconstrain "Bip001 Head" x limit 0 0 0
	$jointconstrain "Bip001 Head" y limit 0 0 0
	$jointconstrain "Bip001 Head" z limit 0 0 0

	$jointconstrain "Bip001 R Hand" x limit 0 0 0
	$jointconstrain "Bip001 R Hand" y limit 0 0 0
	$jointconstrain "Bip001 R Hand" z limit 0 0 0

	$jointconstrain "Bip001 R Foot" x limit 0 0 0
	$jointconstrain "Bip001 R Foot" y limit 0 0 0
	$jointconstrain "Bip001 R Foot" z limit 0 0 0
}

$collisiontext
{
}

$keyvalues
{
	qc_path 
	{
		"value"		"c:\users\pccom\desktop\modelos\- supernews -\zombie test\qc.qc"
	}
	qc_path 
	{
		"value"		"c:\program files (x86)\steam\steamapps\common\counter-strike global offensive\csgo\models\npc\tsx\zombie\decompiled 0.27\zombie.qc"
	}
}
