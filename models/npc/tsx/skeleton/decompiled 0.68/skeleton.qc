// Created by Crowbar 0.68

$modelname "npc/tsx/skeleton/skeleton.mdl"

$bodygroup "head"
{
	studio "head0.smd"
	studio "head1.smd"
	studio "head2.smd"
	studio "head3.smd"
	studio "head4.smd"
}
$bodygroup "body"
{
	studio "ctm_fbi_reference.smd"
	studio "ctm_fbi_reference2.smd"
	studio "ctm_fbi_reference3.smd"
}
$bodygroup "weapon"
{
	studio "bow.smd"
	studio "axe.smd"
	studio "axe_shield.smd"
	studio "mace_shield.smd"
	studio "sword_shield.smd"
}


$surfaceprop "flesh"

$contents "solid"

$illumposition -10.242 -4.117 33.998

$opaque

$cdmaterials "models\npc\tsx\skeleton\"
$cdmaterials ""

$cbox 0 0 0 0 0 0

$bbox -21.977 -47.126 -2.552 30.211 26.643 70.548

$hboxset "default"
$hbox 3 "Bip001 Pelvis" -10.53 -7.74 -9.73 16.530001 9.51 9.73
$hbox 3 "Bip001 Spine" -5.86 -7.41 -13.65 25.59 9.53 13.37
$hbox 1 "Bip001 Neck" -2.32 -6.23 -4.72 2.64 4.09 4.44
$hbox 1 "Bip001 Head" -3.55 -6.77 -5.81 11.58 6.91 5.59
$hbox 4 "Bip001 L UpperArm" -1.88 -5.6 -4.61 14.1 4.74 3.83
$hbox 5 "Bip001 L Forearm" -5.33 -4.23 -3.54 13.86 3.71 3.29
$hbox 5 "Bip001 L Hand" -7.56 -3.11 -5.82 10.34 5.48 3.71
$hbox 4 "Bip001 R UpperArm" -1.78 -7.3 -3.83 14.1 4.52 4.88
$hbox 5 "Bip001 R Forearm" -4.55 -4.42 -3.29 13.86 3.71 4.03
$hbox 5 "Bip001 R Hand" -7.03 -3.11 -3.71 10.34 5.48 5.82
$hbox 6 "Bip001 L Thigh" -6.83 -6.59 -5.1 28.139999 6.76 4.92
$hbox 7 "Bip001 L Calf" -3.88 -6.01 -4.69 15.63 5.06 3.86
$hbox 7 "Bip001 L Foot" -5.46 -5.41 -4.7 4.89 14.22 4.21
$hbox 7 "Bip001 L Toe0" -4.57 -0.25 -4.7 7.82 3.86 4.41
$hbox 6 "Bip001 R Thigh" -6.36 -7.8 -4.42 27.530001 7.14 5.1
$hbox 7 "Bip001 R Calf" -4.1 -6.81 -4.46 15.61 5.02 4.74
$hbox 7 "Bip001 R Foot" -6.28 -5.41 -4.42 4.74 13.3 4.49
$hbox 7 "Bip001 R Toe0" -4.9 -0.2 -4.41 7.71 3.86 4.49

$definebone "Bip001" "" 0 0.660075 39.218254 0 -89.999927 0 0 0 0 0 0 0

$definebone "Bip001 Pelvis" "Bip001" 0 0 0 -89.999982 -89.999927 0 0 0 0 0 0 0
$definebone "Bip001 Spine" "Bip001 Pelvis" 4.058926 -0.006605 0.000006 -0.000057 0.045607 -0.000229 0 0 0 0 0 0
$definebone "Bip001 Spine1" "Bip001 Spine" 8.296783 -0.007307 0 0 0 0 0 0 0 0 0 0

$definebone "Bip001 Neck" "Bip001 Spine1" 10.334957 -1.390764 -0.000002 -0.000057 10.992769 0 0 0 0 0 0 0

$definebone "Bip001 Head" "Bip001 Neck" 4.244904 0.711386 0.000001 0.000057 -11.038492 0 0 0 0 0 0 0
$definebone "Bone_jaw" "Bip001 Head" 1.056587 1.464824 0.000006 -0.000036 125.095174 180.000005 0 0 0 0 0 0

$definebone "Bip001 L Clavicle" "Bip001 Neck" -0.871815 1.586102 1.802917 -79.81354 170.646662 -1.712055 0 0 0 0 0 0
$definebone "Bip001 L UpperArm" "Bip001 L Clavicle" 5.232996 0 -0.000004 66.980885 8.283308 44.223573 0 0 0 0 0 0
$definebone "Bip001 L Forearm" "Bip001 L UpperArm" 13.328007 -0.000002 0.000003 0.000001 -12.73754 0.000002 0 0 0 0 0 0
$definebone "Bip001 L Hand" "Bip001 L Forearm" 9.833141 -0.000001 0.000003 0.22397 -5.074344 -100.116763 0 0 0 0 0 0
$definebone "Bip001 L Finger0" "Bip001 L Hand" 4.411863 -0.000002 0 5.691418 31.455784 -0.039132 0 0 0 0 0 0
$definebone "Bip001 L Thigh" "Bip001 Spine" -4.058926 0.009826 4.384431 0.557338 179.488519 179.976277 0 0 0 0 0 0
$definebone "Bip001 L Calf" "Bip001 L Thigh" 17.647484 0 0 0 -6.451964 0 0 0 0 0 0 0
$definebone "Bip001 L Foot" "Bip001 L Calf" 17.64748 0 0 0.557488 5.986321 -5.428143 0 0 0 0 0 0
$definebone "Bip001 L Toe0" "Bip001 L Foot" 4.058923 5.223657 0.000001 -0.000002 89.999982 0 0 0 0 0 0 0

$definebone "Bip001 R Clavicle" "Bip001 Neck" -0.871826 1.586114 -1.802912 79.813479 170.644941 1.710279 0 0 0 0 0 0
$definebone "Bip001 R UpperArm" "Bip001 R Clavicle" 5.232994 0 -0.000015 -66.980885 8.283311 -44.223573 0 0 0 0 0 0
$definebone "Bip001 R Forearm" "Bip001 R UpperArm" 13.328022 -0.000004 0.000002 -0.000002 -12.73754 -0.000005 0 0 0 0 0 0
$definebone "Bip001 R Hand" "Bip001 R Forearm" 9.833149 0 0.000002 -0.223972 -5.074341 100.116763 0 0 0 0 0 0
$definebone "Bip001 R Finger0" "Bip001 R Hand" 4.411867 -0.000001 -0.000001 -5.691417 31.455777 0.039137 0 0 0 0 0 0
$definebone "Bip001 R Thigh" "Bip001 Spine" -4.058922 0.009851 -4.384432 -0.557297 179.488519 -179.976564 0 0 0 0 0 0
$definebone "Bip001 R Calf" "Bip001 R Thigh" 17.647478 0 0 0 -6.451964 0 0 0 0 0 0 0
$definebone "Bip001 R Foot" "Bip001 R Calf" 17.647482 0 0 -0.557488 5.98632 5.428143 0 0 0 0 0 0
$definebone "Bip001 R Toe0" "Bip001 R Foot" 4.05892 5.223656 0 0.000002 89.999982 0 0 0 0 0 0 0

$definebone "gauntlet_B_L" "Bip001 L Forearm" 2.516476 0.626773 -0.017845 -52.558278 81.738274 -76.427358 0 0 0 0 0 0

$definebone "Bone_pauldron_L" "Bip001 L Clavicle" 3.540968 0.50364 1.575279 4.818117 -0.293355 90.053667 0 0 0 0 0 0
$definebone "Pauldron_A_L" "Bone_pauldron_L" 2.013283 -0.672958 0.510717 0 14.999977 -90.000037 0 0 0 0 0 0
$definebone "Pauldron_B_L" "Bone_pauldron_L" 2.00133 0.26453 0.042789 0 14.999977 -90.000037 0 0 0 0 0 0
$definebone "Bone_pauldron_R" "Bip001 R Clavicle" 3.540635 0.503656 -1.575233 -4.818114 -0.29324 89.946351 0 0 0 0 0 0
$definebone "Pauldron_A_R" "Bone_pauldron_R" 2.013613 0.672867 0.510711 0.000019 165.000035 -90.000016 0 0 0 0 0 0
$definebone "Pauldron_B_R" "Bone_pauldron_R" 2.001659 -0.26461 0.042783 0.000019 165.000035 -90.000016 0 0 0 0 0 0

$definebone "greaves_A_L" "Bip001 L Calf" 6.966492 0.867721 -0.239713 89.44186 -175.977679 -1.963871 0 0 0 0 0 0
$definebone "Fould_add_L" "Bip001 L Thigh" 5.477898 -0.360031 -2.0342 89.44255 177.570274 -1.963928 0 0 0 0 0 0
$definebone "greaves_A_R" "Bip001 R Calf" 6.966499 0.867709 0.239705 89.44255 4.038435 178.052199 0 0 0 0 0 0
$definebone "Fould_add_R" "Bip001 R Thigh" 5.47789 -0.360048 2.034189 89.44255 -2.413586 178.052199 0 0 0 0 0 0
$definebone "Bone_waistF_1" "Bip001 Pelvis" -1.730537 4.126019 -0.000011 0.000091 -180.000005 -179.999827 0 0 0 0 0 0
$definebone "Bone_waistF_2" "Bone_waistF_1" 6.342058 0 0 0 0.965549 0 0 0 0 0 0 0
$definebone "Bone_waistB_1" "Bip001 Pelvis" -0.903313 -3.353476 0.000011 0.000091 179.325975 -179.999827 0 0 0 0 0 0
$definebone "Bone_waistB_2" "Bone_waistB_1" 5.859703 -0.000001 0 0 -1.038944 0 0 0 0 0 0 0
$definebone "gauntlet_A_L" "Bip001 L Forearm" 4.836613 0.426303 -0.360236 -52.558278 81.738274 -76.427358 0 0 0 0 0 0
$definebone "gauntlet_A_R" "Bip001 R Forearm" 4.836601 0.426318 0.360252 -52.558135 -98.26167 103.572592 0 0 0 0 0 0

$definebone "Bone_Bow_A" "Bip001 L Hand" 3.955616 0.784842 -0.410566 -72.816865 111.926119 -21.503054 0 0 0 0 0 0
$definebone "Bone_Bow_B" "Bone_Bow_A" -5.483315 -1.893536 0.000003 -0.000004 155.000092 0.000003 0 0 0 0 0 0
$definebone "Bone_Bow_D" "Bone_Bow_A" 0.000001 6.31411 -0.000001 0 89.999982 0.000005 0 0 0 0 0 0
$definebone "Bone_Bow_C" "Bone_Bow_A" 5.532513 -1.930386 -0.000002 0.000004 25.000034 -0.000056 0 0 0 0 0 0

$definebone "quiver" "Bip001 Spine1" 0.739197 -5.695068 -0.04928 -89.999982 -90.045587 0 0 0 0 0 0 0

$definebone "Bone_weapon_grip" "Bip001 R Hand" 3.840103 0.829638 1.762461 88.294504 145.696309 -124.211197 0 0 0 0 0 0
$definebone "Bone_Arrow" "Bone_weapon_grip" 0.691393 2.790413 0.142546 6.470068 82.364056 115.630718 0 0 0 0 0 0
$definebone "TwoHanded_Axe" "Bone_weapon_grip" -1.770989 -0.259747 -0.002269 -0.503571 90.106267 -89.999941 0 0 0 0 0 0
$definebone "shortSword" "Bone_weapon_grip" 0.298366 -0.25592 -0.002265 -0.503571 90.106267 -89.999941 0 0 0 0 0 0
$definebone "Axe" "Bone_weapon_grip" -2.172151 -0.260498 -0.002264 -0.503571 90.106205 -89.999941 0 0 0 0 0 0
$definebone "Mace" "Bone_weapon_grip" -1.77099 -0.25975 -0.002268 -0.503571 90.106267 -89.999941 0 0 0 0 0 0

$definebone "Bone_shield_grip" "Bip001 L Hand" 3.840557 1.090391 -1.766782 -88.294723 145.70068 124.206785 0 0 0 0 0 0
$definebone "Bone_shield" "Bone_shield_grip" -0.618325 0.593918 -2.249038 4.412919 14.999915 -157.811944 0 0 0 0 0 0
$definebone "shield_A" "Bone_shield" 2.790361 0.072941 -0.413663 -10.000009 90.00003 -89.999982 0 0 0 0 0 0
$definebone "shield_B" "Bone_shield" 4.434834 0.000004 0.000003 -10.000009 89.999975 -89.999982 0 0 0 0 0 0
$definebone "shield_C" "Bone_shield" 3.562582 -0.664375 -0.930375 -11.554379 39.753354 -72.411951 0 0 0 0 0 0

$sectionframes 30 30

$weightlist body_top {
	"Bip001"			0

	"Bip001 Pelvis"		0
	"Bip001 Spine"		1
	"Bip001 Spine1"		1

	"Bip001 Neck"		1

	"Bip001 Head"		1
	"Bone_jaw"			1

	"Bip001 L Clavicle"	1
	"Bip001 L UpperArm"	1
	"Bip001 L Forearm"	1
	"Bip001 L Hand"		1
	"Bip001 L Finger0"	1
	"Bip001 L Thigh"	0
	"Bip001 L Calf"		0
	"Bip001 L Foot"		0
	"Bip001 L Toe0"		0
	
	"Bip001 R Clavicle"	1
	"Bip001 R UpperArm"	1
	"Bip001 R Forearm"	1
	"Bip001 R Hand"		1
	"Bip001 R Finger0"	1
	"Bip001 R Thigh"	0
	"Bip001 R Calf"		0
	"Bip001 R Foot"		0
	"Bip001 R Toe0"		0

	"gauntlet_B_L"		1

	"Bone_pauldron_L"	1
	"Pauldron_A_L"		1
	"Pauldron_B_L"		1
	"Bone_pauldron_R"	1
	"Pauldron_A_R"		1
	"Pauldron_B_R"		1

	"greaves_A_L"		0
	"Fould_add_L"		0
	"greaves_A_R"		0
	"Fould_add_R"		0
	
	"Bone_waistF_1"		0
	"Bone_waistF_2"		0
	"Bone_waistB_1"		0
	"Bone_waistB_2"		0
	
	"gauntlet_A_L"		1
	"gauntlet_A_R"		1

	"Bone_Bow_A"		1
	"Bone_Bow_B"		1
	"Bone_Bow_D"		1
	"Bone_Bow_C"		1

	"quiver"			1

	"Bone_weapon_grip"	1
	"Bone_Arrow"		1
	"TwoHanded_Axe"		1
	"shortSword"		1
	"Axe"				1
	"Mace"				1

	"Bone_shield_grip"	1
	"Bone_shield"		1
	"shield_A"			1
	"shield_B"			1
	"shield_C"			1
}


$sequence "idle_lower" {
	"skeleton_anims\idle_lower.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "walk_lower" {
	"skeleton_anims\walk_lower.smd"
	fadein 0.2
	fadeout 0.2
	fps 28
	loop
}

$sequence "run_lower" {
	"skeleton_anims\run_lower.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
	loop
}

$sequence "melee_L_uper" {
	"skeleton_anims\Run_Shoot_KNIFE_LIGHT_L.smd"
	fadein 0.2
	fadeout 0.2
	fps 50
	weightlist "body_top"
}

$sequence "melee_R_uper" {
	"skeleton_anims\Run_Shoot_KNIFE_LIGHT_R.smd"
	fadein 0.2
	fadeout 0.2
	fps 50
	weightlist "body_top"
}

$sequence "dead" {
	"skeleton_anims\dead.smd"
	fadein 1
	fadeout 0.2
	fps 35
}

$sequence "dead_loop" {
	"skeleton_anims\dead_loop.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
	loop
}

$sequence "shield_idle" {
	"skeleton_anims\shield_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
	loop
}

$sequence "shield_run" {
	"skeleton_anims\shield_run.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
	loop
}

$sequence "shield_attack" {
	"skeleton_anims\shield_attack.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
	weightlist "body_top"
}

$sequence "shield_attack2" {
	"skeleton_anims\shield_attack2.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
	weightlist "body_top"
}

$sequence "twohands_idle" {
	"skeleton_anims\twohands_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
	loop
}

$sequence "twohands_run" {
	"skeleton_anims\twohands_run.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
	loop
}

$sequence "twohands_attack" {
	"skeleton_anims\twohands_attack.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
	weightlist "body_top"
}

$sequence "twohands_attack2" {
	"skeleton_anims\twohands_attack2.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
}

$sequence "bow_idle" {
	"skeleton_anims\bow_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
	loop
}

$sequence "bow_run" {
	"skeleton_anims\bow_run.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
	loop
}

$sequence "bow_attack" {
	"skeleton_anims\bow_attack.smd"
	fadein 0.2
	fadeout 0.2
	fps 35
}

$collisionjoints "skeleton_physics.smd"
{
	$mass 90
	$inertia 10
	$damping 0.01
	$rotdamping 1.5
	$rootbone "Bip001 Pelvis"


	$jointconstrain "Bip001 R Thigh" x limit 0 0 0
	$jointconstrain "Bip001 R Thigh" y limit -25 6 0
	$jointconstrain "Bip001 R Thigh" z limit -15 35 0

	$jointconstrain "Bip001 R Calf" x limit 0 0 0
	$jointconstrain "Bip001 R Calf" y limit 0 0 0
	$jointconstrain "Bip001 R Calf" z limit 0 0 0

	$jointconstrain "Bip001 L Thigh" x limit 0 0 0
	$jointconstrain "Bip001 L Thigh" y limit -25 6 0
	$jointconstrain "Bip001 L Thigh" z limit -15 35 0

	$jointconstrain "Bip001 L Calf" x limit 0 0 0
	$jointconstrain "Bip001 L Calf" y limit 0 0 0
	$jointconstrain "Bip001 L Calf" z limit 0 0 0

	$jointconstrain "Bip001 L Foot" x limit 0 0 0
	$jointconstrain "Bip001 L Foot" y limit 0 0 0
	$jointconstrain "Bip001 L Foot" z limit 0 0 0

	$jointconstrain "Bip001 Spine" x limit -48 48 0
	$jointconstrain "Bip001 Spine" y limit -25 25 0
	$jointconstrain "Bip001 Spine" z limit -25 50 0

	$jointconstrain "Bip001 R UpperArm" x limit 0 0 0
	$jointconstrain "Bip001 R UpperArm" y limit 0 0 0
	$jointconstrain "Bip001 R UpperArm" z limit -8 126 0

	$jointconstrain "Bip001 R Forearm" x limit 0 0 0
	$jointconstrain "Bip001 R Forearm" y limit -25 6 0
	$jointconstrain "Bip001 R Forearm" z limit -15 35 0

	$jointconstrain "Bip001 L UpperArm" x limit 0 0 0
	$jointconstrain "Bip001 L UpperArm" y limit -19 19 0
	$jointconstrain "Bip001 L UpperArm" z limit -15 35 0

	$jointconstrain "Bip001 L Forearm" x limit 0 0 0
	$jointconstrain "Bip001 L Forearm" y limit -25 6 0
	$jointconstrain "Bip001 L Forearm" z limit -15 35 0

	$jointconstrain "Bip001 L Hand" x limit 0 0 0
	$jointconstrain "Bip001 L Hand" y limit 0 0 0
	$jointconstrain "Bip001 L Hand" z limit 0 0 0

	$jointconstrain "Bip001 Head" x limit -25 25 0.08
	$jointconstrain "Bip001 Head" y limit -20 20 0.08
	$jointconstrain "Bip001 Head" z limit -10 35 0.08

	$jointconstrain "Bip001 R Hand" x limit 0 0 0
	$jointconstrain "Bip001 R Hand" y limit 0 0 0
	$jointconstrain "Bip001 R Hand" z limit 0 0 0

	$jointconstrain "Bip001 R Foot" x limit 0 0 0
	$jointconstrain "Bip001 R Foot" y limit 0 0 0
	$jointconstrain "Bip001 R Foot" z limit 0 0 0
}

$keyvalues
{
	qc_path 
	{
		"value"		"c:\users\pccom\desktop\modelos\- supernews -\ts-x\skeleton\qc.qc"
	}
}
