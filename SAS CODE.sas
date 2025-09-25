options nofmterr;

LIBNAME tcga "C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS";
RUN;

proc contents data=tcga.tcga;
run;

proc sort data = tcga.tcga;
by ID;
run;

proc format;
	value TAT 1='Low' 2='High';
	value TSM 1='Low' 2='High';
	value bctype 0='H.M. + L.A.' 1='H.M. + H.A.' 2='L.M. + L.A.' 3='L.M. + H.A.';
	value event 0='Alive' 1='Dead';
run;

data tcga.tcga;
set tcga.tcga;
if sex = 'male' & muscle <153 then TSM1=1;
else if sex = 'male' & muscle >= 153 then TSM1=2;
else if sex = 'female' & muscle <120.7 then TSM1=1;
else if sex = 'female' & muscle >=120.7 then TSM1=2;
run;

data tcga.tcga;
set tcga.tcga;
if sex = 'male' & TAT <239.11 then TAT1=1;
else if sex = 'male' & TAT >=239.11 then TAT1=2;
if sex = 'female' & TAT <383.05 then TAT1=1;
else if sex = 'female' & TAT >=383.05 then TAT1=2;
run;

data tcga.tcga;
set tcga.tcga;
if TSM1 = 2 & TAT1 = 1 then bctype =0;
if TSM1 = 2 & TAT1 = 2 then bctype =1;
if TSM1 = 1 & TAT1 = 1 then bctype =2;
if TSM1 = 1 & TAT1 = 2 then bctype =3;

label TSM1='Total Skeletal Muscle' 
TAT1 = 'Total Adiposity'
bctype = 'Body Composition'
Event = 'Vital Status';
run;


proc freq data= tcga.tcga;
table tsm1*muscle_group tat1*tat_group bctype event cyclin_D1_grp;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

data tcga;
set tcga.tcga;
run;


proc freq data= tcga;
table tsm1*muscle_group tat1*tat_group bctype event cyclin_D1_grp;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

*****table 1 * summary statistics of the sample*****;

* include the codebook macros;
%include "C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\for macro\table_macro.sas";

ODS EXCEL file="C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\Table1-1.xlsx";
%TABLEN(DATA=tcga,
 BY=bctype,
 BYORDER=, 
 BYLABEL=, 
 SHOWTOTAL=1,
 VAR= age sex race ethnicity ajcc_pathologic_stage Event VAT IMAT SAT TAT TAT1 Muscle TSM1,
 TYPE=1 2 2 2 2 2 1 1 1 1 2 1 2)
ODS excel CLOSE;


proc lifetest data= tcga plots=survival(atrisk);*** survival analysis 4 BC categories**;
	where sex = "male";
	strata bctype;
	time followup*event(0);
  	format bctype bctype.;
run; 

proc lifetest data= tcga plots=survival(atrisk);*** survival analysis 4 BC categories**;
	where sex = "female";
	strata bctype;
	time followup*event(0);
  	format bctype bctype.;
run; 

proc lifetest data= tcga plots=survival(atrisk);*** survival analysis 4 BC categories**;
	strata bctype;
	time followup*event(0);
  	format bctype bctype.;
run; 


proc phreg data = tcga;
class bctype(ref="H.M. + H.A.")ajcc_pathologic_stage sex race ethnicity;
model followup*event(0) = bctype ajcc_pathologic_stage sex race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "male";
class bctype(ref="H.M. + H.A.")ajcc_pathologic_stage race ethnicity;
model followup*event(0) = bctype ajcc_pathologic_stage race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "female";
class bctype(ref="H.M. + L.A.")ajcc_pathologic_stage race ethnicity;*HM+HA DID NOT HAVE ANY DEATHS SO WE USE THE NEXT BEST SURVIVAL;
model followup*event(0) = bctype ajcc_pathologic_stage race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run; 


proc phreg data = tcga;
class tsm1(ref="High")ajcc_pathologic_stage sex race ethnicity tat1;
model followup*event(0) = tsm1 ajcc_pathologic_stage tat1 sex race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "male";
class tsm1(ref="High")ajcc_pathologic_stage race tat1 ethnicity;
model followup*event(0) = tsm1 ajcc_pathologic_stage tat1 race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "female";
class tsm1(ref="High")ajcc_pathologic_stage tat1 race ethnicity;*HM+HA DID NOT HAVE ANY DEATHS SO WE USE THE NEXT BEST SURVIVAL;
model followup*event(0) = tsm1 ajcc_pathologic_stage tat1 race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run; 


proc phreg data = tcga;
class tat1(ref="High")ajcc_pathologic_stage sex race ethnicity tsm1;
model followup*event(0) = tat1 ajcc_pathologic_stage tsm1 sex race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "male";
class tat1(ref="High")ajcc_pathologic_stage race tsm1 ethnicity;
model followup*event(0) = tat1 ajcc_pathologic_stage tsm1 race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "female";
class tat1(ref="High")ajcc_pathologic_stage tsm1 race ethnicity;*HM+HA DID NOT HAVE ANY DEATHS SO WE USE THE NEXT BEST SURVIVAL;
model followup*event(0) = tat1 ajcc_pathologic_stage tsm1 race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run; 




**************************************************************************;


proc freq data= tcga;
table tsm1*muscle_group tat1*tat_group bctype event;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;



*****table 1 * summary statistics of the sample*****;

* include the codebook macros;
%include "C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\for macro\table_macro.sas";

ODS EXCEL file="C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\Table1-1.xlsx";
%TABLEN(DATA=tcga,
 BY=bctype,
 BYORDER=, 
 BYLABEL=, 
 SHOWTOTAL=1,
 VAR= age sex race ethnicity ajcc_pathologic_stage Event VAT IMAT SAT TAT TAT1 Muscle TSM1,
 TYPE=1 2 2 2 2 2 1 1 1 1 2 1 2)
ODS excel CLOSE;


proc lifetest data= tcga plots=survival(atrisk);*** survival analysis 4 BC categories**;
	where sex = "male";
	strata bctype;
	time followup*event(0);
  	format bctype bctype.;
run; 

proc lifetest data= tcga plots=survival(atrisk);*** survival analysis 4 BC categories**;
	where sex = "female";
	strata bctype;
	time followup*event(0);
  	format bctype bctype.;
run; 

proc lifetest data= tcga plots=survival(atrisk);*** survival analysis 4 BC categories**;
	strata bctype;
	time followup*event(0);
  	format bctype bctype.;
run; 


proc phreg data = tcga;
class bctype(ref="H.M. + H.A.")ajcc_pathologic_stage sex race ethnicity;
model followup*event(0) = bctype ajcc_pathologic_stage sex race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "male";
class bctype(ref="H.M. + H.A.")ajcc_pathologic_stage race ethnicity;
model followup*event(0) = bctype ajcc_pathologic_stage race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "female";
class bctype(ref="H.M. + L.A.")ajcc_pathologic_stage race ethnicity;*HM+HA DID NOT HAVE ANY DEATHS SO WE USE THE NEXT BEST SURVIVAL;
model followup*event(0) = bctype ajcc_pathologic_stage race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run; 


proc phreg data = tcga;
class tsm1(ref="High")ajcc_pathologic_stage sex race ethnicity tat1;
model followup*event(0) = tsm1 ajcc_pathologic_stage tat1 sex race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "male";
class tsm1(ref="High")ajcc_pathologic_stage race tat1 ethnicity;
model followup*event(0) = tsm1 ajcc_pathologic_stage tat1 race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "female";
class tsm1(ref="High")ajcc_pathologic_stage tat1 race ethnicity;*HM+HA DID NOT HAVE ANY DEATHS SO WE USE THE NEXT BEST SURVIVAL;
model followup*event(0) = tsm1 ajcc_pathologic_stage tat1 race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run; 


proc phreg data = tcga;
class tat1(ref="High")ajcc_pathologic_stage sex race ethnicity tsm1;
model followup*event(0) = tat1 ajcc_pathologic_stage tsm1 sex race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "male";
class tat1(ref="High")ajcc_pathologic_stage race tsm1 ethnicity;
model followup*event(0) = tat1 ajcc_pathologic_stage tsm1 race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run;

proc phreg data = tcga;
where sex = "female";
class tat1(ref="High")ajcc_pathologic_stage tsm1 race ethnicity;*HM+HA DID NOT HAVE ANY DEATHS SO WE USE THE NEXT BEST SURVIVAL;
model followup*event(0) = tat1 ajcc_pathologic_stage tsm1 race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run; 


/*MACRO body composition 1vs0*/

%MACRO ALL(protein, n);

proc glm data = tcga;
  class ajcc_pathologic_stage sex race ethnicity bctype(ref="1");
  model &protein
= bctype age ethnicity sex race ajcc_pathologic_stage / solution ss3;
ods output ParameterEstimates= p (keep= Dependent Parameter Estimate Probt);
run;

data p&n; set p;
  if parameter = "bctype               0" ;/* this saves  1 vs 0 : change the category for other comparisons also in last statement for table creation*/
  run;



%MEND ALL;
%ALL(_4_3_3_epsilon,1);
%ALL(_E_BP1,2);
%ALL(_E_BP1_pS65,3);
%ALL(_E_BP1_pT37_T46,4);
%ALL(_3BP1,5);
%ALL(ACC_pS79,6);
%ALL(ACC1,7);
%ALL(Akt,8);
%ALL(Akt_pS473,9);
%ALL(Akt_pT308,10);
%ALL(AMPK_alpha,11);
%ALL(AMPK_pT172,12);
%ALL(AR,13);
%ALL(ATM,14);
%ALL(Bak,15);
%ALL(Bax,16);
%ALL(Bcl_2,17);
%ALL(Bcl_xL,18);
%ALL(Beclin,19);
%ALL(beta_Catenin,20);
%ALL(Bid,21);
%ALL(Bim,22);
%ALL(c_Jun_pS73,23);
%ALL(c_Kit,24);
%ALL(c_Met_pY1235,25);
%ALL(c_Myc,26);
%ALL(C_Raf,27);
%ALL(C_Raf_pS338,28);
%ALL(Caspase_7_cleavedD198,29);
%ALL(Caveolin_1,30);
%ALL(CD31,31);
%ALL(CD49b,32);
%ALL(CDK1,33);
%ALL(Chk1,34);
%ALL(Chk1_pS345,35);
%ALL(Chk2,36);
%ALL(Chk2_pT68,37);
%ALL(cIAP,38);
%ALL(Claudin_7,39);
%ALL(Collagen_VI,40);
%ALL(Cyclin_B1,41);
%ALL(Cyclin_D1,42);
%ALL(Cyclin_E1,43);
%ALL(DJ_1,44);
%ALL(Dvl3,45);
%ALL(E_Cadherin,46);
%ALL(eEF2,47);
%ALL(EGFR_pY1068,48);
%ALL(EGFR_pY1173,49);
%ALL(eIF4E,50);
%ALL(ER_alpha,51);
%ALL(ER_alpha_pS118,52);
%ALL(ERK2,53);
%ALL(Fibronectin,54);
%ALL(FOXO3a,55);
%ALL(GAB2,56);
%ALL(GATA3,57);
%ALL(GSK3_alpha_beta,58);
%ALL(GSK3_alpha_beta_pS21_S9,59);
%ALL(HER2,60);
%ALL(HER2_pY1248,61);
%ALL(HER3,62);
%ALL(HER3_pY1289,63);
%ALL(HSP70,64);
%ALL(IGFBP2,65);
%ALL(INPP4B,66);
%ALL(IRS1,67);
%ALL(JNK2,68);
%ALL(Ku80,69);
%ALL(Lck,70);
%ALL(LKB1,71);
%ALL(MAPK_pT202_Y204,72);
%ALL(MEK1,73);
%ALL(MEK1_pS217_S221,74);
%ALL(MIG_6,75);
%ALL(Mre11,76);
%ALL(mTOR,77);
%ALL(N_Cadherin,78);
%ALL(NF_kB_p65_pS536,79);
%ALL(NF2,80);
%ALL(Notch1,81);
%ALL(P_Cadherin,82);
%ALL(p27,83);
%ALL(p27_pT157,84);
%ALL(p38_MAPK,85);
%ALL(p38_pT180_Y182,86);
%ALL(p53,87);
%ALL(p70S6K,88);
%ALL(p70S6K_pT389,89);
%ALL(p90RSK_pT359_S363,90);
%ALL(Paxillin,91);
%ALL(PCNA,92);
%ALL(PDK1_pS241,93);
%ALL(PEA15,94);
%ALL(PI3K_p110_alpha,95);
%ALL(PKC_alpha,96);
%ALL(PKC_alpha_pS657,97);
%ALL(PKC_delta_pS664,98);
%ALL(PR,99);
%ALL(PRAS40_pT246,100);
%ALL(PTEN,101);
%ALL(Rad50,102);
%ALL(Rad51,103);
%ALL(Rb_pS807_S811,104);
%ALL(S6,105);
%ALL(S6_pS235_S236,106);
%ALL(S6_pS240_S244,107);
%ALL(Shc_pY317,108);
%ALL(Smad1,109);
%ALL(Smad3,110);
%ALL(Smad4,111);
%ALL(Src,112);
%ALL(Src_pY416,113);
%ALL(Src_pY527,114);
%ALL(STAT3_pY705,115);
%ALL(STAT5_alpha,116);
%ALL(Stathmin,117);
%ALL(Syk,118);
%ALL(Tuberin,119);
%ALL(VEGFR2,120);
%ALL(XRCC1,121);
%ALL(YAP,122);
%ALL(YAP_pS127,123);
%ALL(YB_1,124);
%ALL(YB_1_pS102,125);
%ALL(JNK_pT183_pY185,126);
%ALL(PAI_1,127);
%ALL(mTOR_pS2448,128);
%ALL(ASNS,129);
%ALL(EGFR,130);
%ALL(eEF2K,131);
%ALL(_E_BP1_pT70,132);
%ALL(A_Raf_pS299,133);
%ALL(Acetyl_a_Tubulin_Lys40,134);
%ALL(Annexin_VII,135);
%ALL(ARID1A,136);
%ALL(B_Raf,137);
%ALL(Bad_pS112,138);
%ALL(Bap1_c_4,139);
%ALL(BRCA2,140);
%ALL(CD20,141);
%ALL(Cyclin_E2,142);
%ALL(eIF4G,143);
%ALL(ETS_1,144);
%ALL(FASN,145);
%ALL(FOXO3a_pS318_S321,146);
%ALL(FoxM1,147);
%ALL(G6PD,148);
%ALL(GAPDH,149);
%ALL(GSK3_pS9,150);
%ALL(Heregulin,151);
%ALL(MYH11,152);
%ALL(Myosin_IIa_pS1943,153);
%ALL(N_Ras,154);
%ALL(NDRG1_pT346,155);
%ALL(p21,156);
%ALL(p27_pT198,157);
%ALL(p62_LCK_ligand,158);
%ALL(p90RSK,159);
%ALL(PDCD4,160);
%ALL(PDK1,161);
%ALL(PI3K_p85,162);
%ALL(PKC_pan_BetaII_pS660,163);
%ALL(PRDX1,164);
%ALL(Rab25,165);
%ALL(Rab11,166);
%ALL(Raptor,167);
%ALL(RBM15,168);
%ALL(Rictor,169);
%ALL(Rictor_pT1135,170);
%ALL(SCD,171);
%ALL(SF2,172);
%ALL(TAZ,173);
%ALL(TIGAR,174);
%ALL(TFRC,175);
%ALL(TSC1,176);
%ALL(Tuberin_pT1462,177);
%ALL(EPPK1,178);
%ALL(XBP1,179);
%ALL(PEA15_pS116,180);
%ALL(Transglutaminase,181);
%ALL(_4_3_3_beta,182);
%ALL(_4_3_3_zeta,183);
%ALL(ACVRL1,184);
%ALL(DIRAS3,185);
%ALL(Annexin_1,186);
%ALL(PREX1,187);
%ALL(ADAR1,188);
%ALL(JAB1,189);
%ALL(c_Met,190);
%ALL(Caspase_8,191);
%ALL(ERCC1,192);
%ALL(MSH2,193);
%ALL(MSH6,194);
%ALL(PARP_cleaved,195);
%ALL(Rb,196);
%ALL(SETD2,197);
%ALL(Smac,198);
%ALL(Snail,199);
%ALL(GATA6,200);
%ALL(A_Raf,201);
%ALL(B_Raf_pS445,202);
%ALL(Bcl2A1,203);
%ALL(BRD4,204);
%ALL(c_Abl,205);
%ALL(Caspase_3,206);
%ALL(CD26,207);
%ALL(Chk1_pS296,208);
%ALL(COG3,209);
%ALL(DUSP4,210);
%ALL(ERCC5,211);
%ALL(IGF1R_pY1135_Y1136,212);
%ALL(IRF_1,213);
%ALL(Jak2,214);
%ALL(p16_INK4a,215);
%ALL(SHP_2_pY542,216);
%ALL(CDK1_pY15,217);
%ALL(CA9,218);
%ALL(Complex_II_subunit30,219);
%ALL(GYG_Glycogenin1,220);
%ALL(GYS,221);
%ALL(GYS_pS641,222);
%ALL(HIF_1_alpha,223);
%ALL(LDHA,224);
%ALL(LDHB,225);
%ALL(Mitochondria,226);
%ALL(Oxphos_complex_V_subunitb,227);
%ALL(PKM2,228);
%ALL(PYGB,229);
%ALL(PYGB_AB2,230);
%ALL(PYGL,231);
%ALL(PYGM,232);
%ALL(PD_L1,233);



data tcga.bctype_zerovsone;
	set p1-p233;
run;


/*MACRO for TSM*/

%MACRO ALL(protein, n);

proc glm data = tcga;
  class ajcc_pathologic_stage sex race ethnicity TSM1 TAT1(ref="2");/*MACRO for tat SWITCH tsm1 WITH tat1*/
  model &protein
= TAT1 age ethnicity sex race ajcc_pathologic_stage TSM1 / solution ss3;/*MACRO for tat SWITCH tsm1 WITH tat1*/
ods output ParameterEstimates= p (keep= Dependent Parameter Estimate Probt);
run;

data p&n; set p;
  if parameter = "TAT1                 1" ;/*MACRO for tat SWITCH tsm1 WITH tat1*/
  run;



%MEND ALL;
%ALL(_4_3_3_epsilon,1);
%ALL(_E_BP1,2);
%ALL(_E_BP1_pS65,3);
%ALL(_E_BP1_pT37_T46,4);
%ALL(_3BP1,5);
%ALL(ACC_pS79,6);
%ALL(ACC1,7);
%ALL(Akt,8);
%ALL(Akt_pS473,9);
%ALL(Akt_pT308,10);
%ALL(AMPK_alpha,11);
%ALL(AMPK_pT172,12);
%ALL(AR,13);
%ALL(ATM,14);
%ALL(Bak,15);
%ALL(Bax,16);
%ALL(Bcl_2,17);
%ALL(Bcl_xL,18);
%ALL(Beclin,19);
%ALL(beta_Catenin,20);
%ALL(Bid,21);
%ALL(Bim,22);
%ALL(c_Jun_pS73,23);
%ALL(c_Kit,24);
%ALL(c_Met_pY1235,25);
%ALL(c_Myc,26);
%ALL(C_Raf,27);
%ALL(C_Raf_pS338,28);
%ALL(Caspase_7_cleavedD198,29);
%ALL(Caveolin_1,30);
%ALL(CD31,31);
%ALL(CD49b,32);
%ALL(CDK1,33);
%ALL(Chk1,34);
%ALL(Chk1_pS345,35);
%ALL(Chk2,36);
%ALL(Chk2_pT68,37);
%ALL(cIAP,38);
%ALL(Claudin_7,39);
%ALL(Collagen_VI,40);
%ALL(Cyclin_B1,41);
%ALL(Cyclin_D1,42);
%ALL(Cyclin_E1,43);
%ALL(DJ_1,44);
%ALL(Dvl3,45);
%ALL(E_Cadherin,46);
%ALL(eEF2,47);
%ALL(EGFR_pY1068,48);
%ALL(EGFR_pY1173,49);
%ALL(eIF4E,50);
%ALL(ER_alpha,51);
%ALL(ER_alpha_pS118,52);
%ALL(ERK2,53);
%ALL(Fibronectin,54);
%ALL(FOXO3a,55);
%ALL(GAB2,56);
%ALL(GATA3,57);
%ALL(GSK3_alpha_beta,58);
%ALL(GSK3_alpha_beta_pS21_S9,59);
%ALL(HER2,60);
%ALL(HER2_pY1248,61);
%ALL(HER3,62);
%ALL(HER3_pY1289,63);
%ALL(HSP70,64);
%ALL(IGFBP2,65);
%ALL(INPP4B,66);
%ALL(IRS1,67);
%ALL(JNK2,68);
%ALL(Ku80,69);
%ALL(Lck,70);
%ALL(LKB1,71);
%ALL(MAPK_pT202_Y204,72);
%ALL(MEK1,73);
%ALL(MEK1_pS217_S221,74);
%ALL(MIG_6,75);
%ALL(Mre11,76);
%ALL(mTOR,77);
%ALL(N_Cadherin,78);
%ALL(NF_kB_p65_pS536,79);
%ALL(NF2,80);
%ALL(Notch1,81);
%ALL(P_Cadherin,82);
%ALL(p27,83);
%ALL(p27_pT157,84);
%ALL(p38_MAPK,85);
%ALL(p38_pT180_Y182,86);
%ALL(p53,87);
%ALL(p70S6K,88);
%ALL(p70S6K_pT389,89);
%ALL(p90RSK_pT359_S363,90);
%ALL(Paxillin,91);
%ALL(PCNA,92);
%ALL(PDK1_pS241,93);
%ALL(PEA15,94);
%ALL(PI3K_p110_alpha,95);
%ALL(PKC_alpha,96);
%ALL(PKC_alpha_pS657,97);
%ALL(PKC_delta_pS664,98);
%ALL(PR,99);
%ALL(PRAS40_pT246,100);
%ALL(PTEN,101);
%ALL(Rad50,102);
%ALL(Rad51,103);
%ALL(Rb_pS807_S811,104);
%ALL(S6,105);
%ALL(S6_pS235_S236,106);
%ALL(S6_pS240_S244,107);
%ALL(Shc_pY317,108);
%ALL(Smad1,109);
%ALL(Smad3,110);
%ALL(Smad4,111);
%ALL(Src,112);
%ALL(Src_pY416,113);
%ALL(Src_pY527,114);
%ALL(STAT3_pY705,115);
%ALL(STAT5_alpha,116);
%ALL(Stathmin,117);
%ALL(Syk,118);
%ALL(Tuberin,119);
%ALL(VEGFR2,120);
%ALL(XRCC1,121);
%ALL(YAP,122);
%ALL(YAP_pS127,123);
%ALL(YB_1,124);
%ALL(YB_1_pS102,125);
%ALL(JNK_pT183_pY185,126);
%ALL(PAI_1,127);
%ALL(mTOR_pS2448,128);
%ALL(ASNS,129);
%ALL(EGFR,130);
%ALL(eEF2K,131);
%ALL(_E_BP1_pT70,132);
%ALL(A_Raf_pS299,133);
%ALL(Acetyl_a_Tubulin_Lys40,134);
%ALL(Annexin_VII,135);
%ALL(ARID1A,136);
%ALL(B_Raf,137);
%ALL(Bad_pS112,138);
%ALL(Bap1_c_4,139);
%ALL(BRCA2,140);
%ALL(CD20,141);
%ALL(Cyclin_E2,142);
%ALL(eIF4G,143);
%ALL(ETS_1,144);
%ALL(FASN,145);
%ALL(FOXO3a_pS318_S321,146);
%ALL(FoxM1,147);
%ALL(G6PD,148);
%ALL(GAPDH,149);
%ALL(GSK3_pS9,150);
%ALL(Heregulin,151);
%ALL(MYH11,152);
%ALL(Myosin_IIa_pS1943,153);
%ALL(N_Ras,154);
%ALL(NDRG1_pT346,155);
%ALL(p21,156);
%ALL(p27_pT198,157);
%ALL(p62_LCK_ligand,158);
%ALL(p90RSK,159);
%ALL(PDCD4,160);
%ALL(PDK1,161);
%ALL(PI3K_p85,162);
%ALL(PKC_pan_BetaII_pS660,163);
%ALL(PRDX1,164);
%ALL(Rab25,165);
%ALL(Rab11,166);
%ALL(Raptor,167);
%ALL(RBM15,168);
%ALL(Rictor,169);
%ALL(Rictor_pT1135,170);
%ALL(SCD,171);
%ALL(SF2,172);
%ALL(TAZ,173);
%ALL(TIGAR,174);
%ALL(TFRC,175);
%ALL(TSC1,176);
%ALL(Tuberin_pT1462,177);
%ALL(EPPK1,178);
%ALL(XBP1,179);
%ALL(PEA15_pS116,180);
%ALL(Transglutaminase,181);
%ALL(_4_3_3_beta,182);
%ALL(_4_3_3_zeta,183);
%ALL(ACVRL1,184);
%ALL(DIRAS3,185);
%ALL(Annexin_1,186);
%ALL(PREX1,187);
%ALL(ADAR1,188);
%ALL(JAB1,189);
%ALL(c_Met,190);
%ALL(Caspase_8,191);
%ALL(ERCC1,192);
%ALL(MSH2,193);
%ALL(MSH6,194);
%ALL(PARP_cleaved,195);
%ALL(Rb,196);
%ALL(SETD2,197);
%ALL(Smac,198);
%ALL(Snail,199);
%ALL(GATA6,200);
%ALL(A_Raf,201);
%ALL(B_Raf_pS445,202);
%ALL(Bcl2A1,203);
%ALL(BRD4,204);
%ALL(c_Abl,205);
%ALL(Caspase_3,206);
%ALL(CD26,207);
%ALL(Chk1_pS296,208);
%ALL(COG3,209);
%ALL(DUSP4,210);
%ALL(ERCC5,211);
%ALL(IGF1R_pY1135_Y1136,212);
%ALL(IRF_1,213);
%ALL(Jak2,214);
%ALL(p16_INK4a,215);
%ALL(SHP_2_pY542,216);
%ALL(CDK1_pY15,217);
%ALL(CA9,218);
%ALL(Complex_II_subunit30,219);
%ALL(GYG_Glycogenin1,220);
%ALL(GYS,221);
%ALL(GYS_pS641,222);
%ALL(HIF_1_alpha,223);
%ALL(LDHA,224);
%ALL(LDHB,225);
%ALL(Mitochondria,226);
%ALL(Oxphos_complex_V_subunitb,227);
%ALL(PKM2,228);
%ALL(PYGB,229);
%ALL(PYGB_AB2,230);
%ALL(PYGL,231);
%ALL(PYGM,232);
%ALL(PD_L1,233);


data tcga.TATHVSL;
	set p1-p233;
run;


*******************************************************************************************************************/

/*MACRO MALE ONLY*/

/*MACRO body composition*/

%MACRO ALL(protein, n);

proc glm data = tcga;
  where sex = "female";
  class ajcc_pathologic_stage race ethnicity bctype(ref="1");
  model &protein
= bctype age ethnicity race ajcc_pathologic_stage / solution ss3;
ods output ParameterEstimates= p (keep= Dependent Parameter Estimate Probt);
run;

data p&n; set p;
  if parameter = "bctype               0" ;/* this saves  1 vs 0 : change the category for other comparisons also in last statement for table creation*/
  run;



%MEND ALL;
%ALL(_4_3_3_epsilon,1);
%ALL(_E_BP1,2);
%ALL(_E_BP1_pS65,3);
%ALL(_E_BP1_pT37_T46,4);
%ALL(_3BP1,5);
%ALL(ACC_pS79,6);
%ALL(ACC1,7);
%ALL(Akt,8);
%ALL(Akt_pS473,9);
%ALL(Akt_pT308,10);
%ALL(AMPK_alpha,11);
%ALL(AMPK_pT172,12);
%ALL(AR,13);
%ALL(ATM,14);
%ALL(Bak,15);
%ALL(Bax,16);
%ALL(Bcl_2,17);
%ALL(Bcl_xL,18);
%ALL(Beclin,19);
%ALL(beta_Catenin,20);
%ALL(Bid,21);
%ALL(Bim,22);
%ALL(c_Jun_pS73,23);
%ALL(c_Kit,24);
%ALL(c_Met_pY1235,25);
%ALL(c_Myc,26);
%ALL(C_Raf,27);
%ALL(C_Raf_pS338,28);
%ALL(Caspase_7_cleavedD198,29);
%ALL(Caveolin_1,30);
%ALL(CD31,31);
%ALL(CD49b,32);
%ALL(CDK1,33);
%ALL(Chk1,34);
%ALL(Chk1_pS345,35);
%ALL(Chk2,36);
%ALL(Chk2_pT68,37);
%ALL(cIAP,38);
%ALL(Claudin_7,39);
%ALL(Collagen_VI,40);
%ALL(Cyclin_B1,41);
%ALL(Cyclin_D1,42);
%ALL(Cyclin_E1,43);
%ALL(DJ_1,44);
%ALL(Dvl3,45);
%ALL(E_Cadherin,46);
%ALL(eEF2,47);
%ALL(EGFR_pY1068,48);
%ALL(EGFR_pY1173,49);
%ALL(eIF4E,50);
%ALL(ER_alpha,51);
%ALL(ER_alpha_pS118,52);
%ALL(ERK2,53);
%ALL(Fibronectin,54);
%ALL(FOXO3a,55);
%ALL(GAB2,56);
%ALL(GATA3,57);
%ALL(GSK3_alpha_beta,58);
%ALL(GSK3_alpha_beta_pS21_S9,59);
%ALL(HER2,60);
%ALL(HER2_pY1248,61);
%ALL(HER3,62);
%ALL(HER3_pY1289,63);
%ALL(HSP70,64);
%ALL(IGFBP2,65);
%ALL(INPP4B,66);
%ALL(IRS1,67);
%ALL(JNK2,68);
%ALL(Ku80,69);
%ALL(Lck,70);
%ALL(LKB1,71);
%ALL(MAPK_pT202_Y204,72);
%ALL(MEK1,73);
%ALL(MEK1_pS217_S221,74);
%ALL(MIG_6,75);
%ALL(Mre11,76);
%ALL(mTOR,77);
%ALL(N_Cadherin,78);
%ALL(NF_kB_p65_pS536,79);
%ALL(NF2,80);
%ALL(Notch1,81);
%ALL(P_Cadherin,82);
%ALL(p27,83);
%ALL(p27_pT157,84);
%ALL(p38_MAPK,85);
%ALL(p38_pT180_Y182,86);
%ALL(p53,87);
%ALL(p70S6K,88);
%ALL(p70S6K_pT389,89);
%ALL(p90RSK_pT359_S363,90);
%ALL(Paxillin,91);
%ALL(PCNA,92);
%ALL(PDK1_pS241,93);
%ALL(PEA15,94);
%ALL(PI3K_p110_alpha,95);
%ALL(PKC_alpha,96);
%ALL(PKC_alpha_pS657,97);
%ALL(PKC_delta_pS664,98);
%ALL(PR,99);
%ALL(PRAS40_pT246,100);
%ALL(PTEN,101);
%ALL(Rad50,102);
%ALL(Rad51,103);
%ALL(Rb_pS807_S811,104);
%ALL(S6,105);
%ALL(S6_pS235_S236,106);
%ALL(S6_pS240_S244,107);
%ALL(Shc_pY317,108);
%ALL(Smad1,109);
%ALL(Smad3,110);
%ALL(Smad4,111);
%ALL(Src,112);
%ALL(Src_pY416,113);
%ALL(Src_pY527,114);
%ALL(STAT3_pY705,115);
%ALL(STAT5_alpha,116);
%ALL(Stathmin,117);
%ALL(Syk,118);
%ALL(Tuberin,119);
%ALL(VEGFR2,120);
%ALL(XRCC1,121);
%ALL(YAP,122);
%ALL(YAP_pS127,123);
%ALL(YB_1,124);
%ALL(YB_1_pS102,125);
%ALL(JNK_pT183_pY185,126);
%ALL(PAI_1,127);
%ALL(mTOR_pS2448,128);
%ALL(ASNS,129);
%ALL(EGFR,130);
%ALL(eEF2K,131);
%ALL(_E_BP1_pT70,132);
%ALL(A_Raf_pS299,133);
%ALL(Acetyl_a_Tubulin_Lys40,134);
%ALL(Annexin_VII,135);
%ALL(ARID1A,136);
%ALL(B_Raf,137);
%ALL(Bad_pS112,138);
%ALL(Bap1_c_4,139);
%ALL(BRCA2,140);
%ALL(CD20,141);
%ALL(Cyclin_E2,142);
%ALL(eIF4G,143);
%ALL(ETS_1,144);
%ALL(FASN,145);
%ALL(FOXO3a_pS318_S321,146);
%ALL(FoxM1,147);
%ALL(G6PD,148);
%ALL(GAPDH,149);
%ALL(GSK3_pS9,150);
%ALL(Heregulin,151);
%ALL(MYH11,152);
%ALL(Myosin_IIa_pS1943,153);
%ALL(N_Ras,154);
%ALL(NDRG1_pT346,155);
%ALL(p21,156);
%ALL(p27_pT198,157);
%ALL(p62_LCK_ligand,158);
%ALL(p90RSK,159);
%ALL(PDCD4,160);
%ALL(PDK1,161);
%ALL(PI3K_p85,162);
%ALL(PKC_pan_BetaII_pS660,163);
%ALL(PRDX1,164);
%ALL(Rab25,165);
%ALL(Rab11,166);
%ALL(Raptor,167);
%ALL(RBM15,168);
%ALL(Rictor,169);
%ALL(Rictor_pT1135,170);
%ALL(SCD,171);
%ALL(SF2,172);
%ALL(TAZ,173);
%ALL(TIGAR,174);
%ALL(TFRC,175);
%ALL(TSC1,176);
%ALL(Tuberin_pT1462,177);
%ALL(EPPK1,178);
%ALL(XBP1,179);
%ALL(PEA15_pS116,180);
%ALL(Transglutaminase,181);
%ALL(_4_3_3_beta,182);
%ALL(_4_3_3_zeta,183);
%ALL(ACVRL1,184);
%ALL(DIRAS3,185);
%ALL(Annexin_1,186);
%ALL(PREX1,187);
%ALL(ADAR1,188);
%ALL(JAB1,189);
%ALL(c_Met,190);
%ALL(Caspase_8,191);
%ALL(ERCC1,192);
%ALL(MSH2,193);
%ALL(MSH6,194);
%ALL(PARP_cleaved,195);
%ALL(Rb,196);
%ALL(SETD2,197);
%ALL(Smac,198);
%ALL(Snail,199);
%ALL(GATA6,200);
%ALL(A_Raf,201);
%ALL(B_Raf_pS445,202);
%ALL(Bcl2A1,203);
%ALL(BRD4,204);
%ALL(c_Abl,205);
%ALL(Caspase_3,206);
%ALL(CD26,207);
%ALL(Chk1_pS296,208);
%ALL(COG3,209);
%ALL(DUSP4,210);
%ALL(ERCC5,211);
%ALL(IGF1R_pY1135_Y1136,212);
%ALL(IRF_1,213);
%ALL(Jak2,214);
%ALL(p16_INK4a,215);
%ALL(SHP_2_pY542,216);
%ALL(CDK1_pY15,217);
%ALL(CA9,218);
%ALL(Complex_II_subunit30,219);
%ALL(GYG_Glycogenin1,220);
%ALL(GYS,221);
%ALL(GYS_pS641,222);
%ALL(HIF_1_alpha,223);
%ALL(LDHA,224);
%ALL(LDHB,225);
%ALL(Mitochondria,226);
%ALL(Oxphos_complex_V_subunitb,227);
%ALL(PKM2,228);
%ALL(PYGB,229);
%ALL(PYGB_AB2,230);
%ALL(PYGL,231);
%ALL(PYGM,232);
%ALL(PD_L1,233);



data tcga.bctypeFEMALE_ZEROvsone;
	set p1-p233;
run;


/*MACRO for TSM*/

%MACRO ALL(protein, n);

proc glm data = tcga;
where sex="male";
  class ajcc_pathologic_stage sex race ethnicity TAT1 TSM1(ref="2");/*MACRO for tat SWITCH tsm1 WITH tat1*/
  model &protein
= TSM1 age ethnicity sex race ajcc_pathologic_stage TAT1 / solution ss3;/*MACRO for tat SWITCH tsm1 WITH tat1*/
ods output ParameterEstimates= p (keep= Dependent Parameter Estimate Probt);
run;

data p&n; set p;
  if parameter = "TSM1                 1" ;/*MACRO for tat SWITCH tsm1 WITH tat1*/
  run;



%MEND ALL;
%ALL(_4_3_3_epsilon,1);
%ALL(_E_BP1,2);
%ALL(_E_BP1_pS65,3);
%ALL(_E_BP1_pT37_T46,4);
%ALL(_3BP1,5);
%ALL(ACC_pS79,6);
%ALL(ACC1,7);
%ALL(Akt,8);
%ALL(Akt_pS473,9);
%ALL(Akt_pT308,10);
%ALL(AMPK_alpha,11);
%ALL(AMPK_pT172,12);
%ALL(AR,13);
%ALL(ATM,14);
%ALL(Bak,15);
%ALL(Bax,16);
%ALL(Bcl_2,17);
%ALL(Bcl_xL,18);
%ALL(Beclin,19);
%ALL(beta_Catenin,20);
%ALL(Bid,21);
%ALL(Bim,22);
%ALL(c_Jun_pS73,23);
%ALL(c_Kit,24);
%ALL(c_Met_pY1235,25);
%ALL(c_Myc,26);
%ALL(C_Raf,27);
%ALL(C_Raf_pS338,28);
%ALL(Caspase_7_cleavedD198,29);
%ALL(Caveolin_1,30);
%ALL(CD31,31);
%ALL(CD49b,32);
%ALL(CDK1,33);
%ALL(Chk1,34);
%ALL(Chk1_pS345,35);
%ALL(Chk2,36);
%ALL(Chk2_pT68,37);
%ALL(cIAP,38);
%ALL(Claudin_7,39);
%ALL(Collagen_VI,40);
%ALL(Cyclin_B1,41);
%ALL(Cyclin_D1,42);
%ALL(Cyclin_E1,43);
%ALL(DJ_1,44);
%ALL(Dvl3,45);
%ALL(E_Cadherin,46);
%ALL(eEF2,47);
%ALL(EGFR_pY1068,48);
%ALL(EGFR_pY1173,49);
%ALL(eIF4E,50);
%ALL(ER_alpha,51);
%ALL(ER_alpha_pS118,52);
%ALL(ERK2,53);
%ALL(Fibronectin,54);
%ALL(FOXO3a,55);
%ALL(GAB2,56);
%ALL(GATA3,57);
%ALL(GSK3_alpha_beta,58);
%ALL(GSK3_alpha_beta_pS21_S9,59);
%ALL(HER2,60);
%ALL(HER2_pY1248,61);
%ALL(HER3,62);
%ALL(HER3_pY1289,63);
%ALL(HSP70,64);
%ALL(IGFBP2,65);
%ALL(INPP4B,66);
%ALL(IRS1,67);
%ALL(JNK2,68);
%ALL(Ku80,69);
%ALL(Lck,70);
%ALL(LKB1,71);
%ALL(MAPK_pT202_Y204,72);
%ALL(MEK1,73);
%ALL(MEK1_pS217_S221,74);
%ALL(MIG_6,75);
%ALL(Mre11,76);
%ALL(mTOR,77);
%ALL(N_Cadherin,78);
%ALL(NF_kB_p65_pS536,79);
%ALL(NF2,80);
%ALL(Notch1,81);
%ALL(P_Cadherin,82);
%ALL(p27,83);
%ALL(p27_pT157,84);
%ALL(p38_MAPK,85);
%ALL(p38_pT180_Y182,86);
%ALL(p53,87);
%ALL(p70S6K,88);
%ALL(p70S6K_pT389,89);
%ALL(p90RSK_pT359_S363,90);
%ALL(Paxillin,91);
%ALL(PCNA,92);
%ALL(PDK1_pS241,93);
%ALL(PEA15,94);
%ALL(PI3K_p110_alpha,95);
%ALL(PKC_alpha,96);
%ALL(PKC_alpha_pS657,97);
%ALL(PKC_delta_pS664,98);
%ALL(PR,99);
%ALL(PRAS40_pT246,100);
%ALL(PTEN,101);
%ALL(Rad50,102);
%ALL(Rad51,103);
%ALL(Rb_pS807_S811,104);
%ALL(S6,105);
%ALL(S6_pS235_S236,106);
%ALL(S6_pS240_S244,107);
%ALL(Shc_pY317,108);
%ALL(Smad1,109);
%ALL(Smad3,110);
%ALL(Smad4,111);
%ALL(Src,112);
%ALL(Src_pY416,113);
%ALL(Src_pY527,114);
%ALL(STAT3_pY705,115);
%ALL(STAT5_alpha,116);
%ALL(Stathmin,117);
%ALL(Syk,118);
%ALL(Tuberin,119);
%ALL(VEGFR2,120);
%ALL(XRCC1,121);
%ALL(YAP,122);
%ALL(YAP_pS127,123);
%ALL(YB_1,124);
%ALL(YB_1_pS102,125);
%ALL(JNK_pT183_pY185,126);
%ALL(PAI_1,127);
%ALL(mTOR_pS2448,128);
%ALL(ASNS,129);
%ALL(EGFR,130);
%ALL(eEF2K,131);
%ALL(_E_BP1_pT70,132);
%ALL(A_Raf_pS299,133);
%ALL(Acetyl_a_Tubulin_Lys40,134);
%ALL(Annexin_VII,135);
%ALL(ARID1A,136);
%ALL(B_Raf,137);
%ALL(Bad_pS112,138);
%ALL(Bap1_c_4,139);
%ALL(BRCA2,140);
%ALL(CD20,141);
%ALL(Cyclin_E2,142);
%ALL(eIF4G,143);
%ALL(ETS_1,144);
%ALL(FASN,145);
%ALL(FOXO3a_pS318_S321,146);
%ALL(FoxM1,147);
%ALL(G6PD,148);
%ALL(GAPDH,149);
%ALL(GSK3_pS9,150);
%ALL(Heregulin,151);
%ALL(MYH11,152);
%ALL(Myosin_IIa_pS1943,153);
%ALL(N_Ras,154);
%ALL(NDRG1_pT346,155);
%ALL(p21,156);
%ALL(p27_pT198,157);
%ALL(p62_LCK_ligand,158);
%ALL(p90RSK,159);
%ALL(PDCD4,160);
%ALL(PDK1,161);
%ALL(PI3K_p85,162);
%ALL(PKC_pan_BetaII_pS660,163);
%ALL(PRDX1,164);
%ALL(Rab25,165);
%ALL(Rab11,166);
%ALL(Raptor,167);
%ALL(RBM15,168);
%ALL(Rictor,169);
%ALL(Rictor_pT1135,170);
%ALL(SCD,171);
%ALL(SF2,172);
%ALL(TAZ,173);
%ALL(TIGAR,174);
%ALL(TFRC,175);
%ALL(TSC1,176);
%ALL(Tuberin_pT1462,177);
%ALL(EPPK1,178);
%ALL(XBP1,179);
%ALL(PEA15_pS116,180);
%ALL(Transglutaminase,181);
%ALL(_4_3_3_beta,182);
%ALL(_4_3_3_zeta,183);
%ALL(ACVRL1,184);
%ALL(DIRAS3,185);
%ALL(Annexin_1,186);
%ALL(PREX1,187);
%ALL(ADAR1,188);
%ALL(JAB1,189);
%ALL(c_Met,190);
%ALL(Caspase_8,191);
%ALL(ERCC1,192);
%ALL(MSH2,193);
%ALL(MSH6,194);
%ALL(PARP_cleaved,195);
%ALL(Rb,196);
%ALL(SETD2,197);
%ALL(Smac,198);
%ALL(Snail,199);
%ALL(GATA6,200);
%ALL(A_Raf,201);
%ALL(B_Raf_pS445,202);
%ALL(Bcl2A1,203);
%ALL(BRD4,204);
%ALL(c_Abl,205);
%ALL(Caspase_3,206);
%ALL(CD26,207);
%ALL(Chk1_pS296,208);
%ALL(COG3,209);
%ALL(DUSP4,210);
%ALL(ERCC5,211);
%ALL(IGF1R_pY1135_Y1136,212);
%ALL(IRF_1,213);
%ALL(Jak2,214);
%ALL(p16_INK4a,215);
%ALL(SHP_2_pY542,216);
%ALL(CDK1_pY15,217);
%ALL(CA9,218);
%ALL(Complex_II_subunit30,219);
%ALL(GYG_Glycogenin1,220);
%ALL(GYS,221);
%ALL(GYS_pS641,222);
%ALL(HIF_1_alpha,223);
%ALL(LDHA,224);
%ALL(LDHB,225);
%ALL(Mitochondria,226);
%ALL(Oxphos_complex_V_subunitb,227);
%ALL(PKM2,228);
%ALL(PYGB,229);
%ALL(PYGB_AB2,230);
%ALL(PYGL,231);
%ALL(PYGM,232);
%ALL(PD_L1,233);


data tcga.maleTsmHVSL;
	set p1-p233;
run;


*************************************************************


/*FDR TYPE 0VS 2*/;
data Tsmhvsl_fdr;
set tcga.Tsmhvsl;
rename Probt = raw_p;
drop Parameter Estimate;
run;

proc multtest pdata=Tsmhvsl_fdr bon fdr;
run;



data tcga2;
set tcga;
if bctype = 0 then bctypetwo = 1;
else IF bctype = 1 then  bctypetwo = 1;
else if bctype = 2 then bctypetwo = 2; 
else if bctype = 3 then bctypetwo = 3; 
RUN;


proc phreg data = tcga2;
where sex = "female";
class bctypetwo(ref="1")ajcc_pathologic_stage race ethnicity;*HM+HA DID NOT HAVE ANY DEATHS SO WE USE THE NEXT BEST SURVIVAL;
model followup*event(0) = bctypetwo ajcc_pathologic_stage race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run; 



data tcgafemale;
set tcga2;
where sex = "female";
RUN;


*****table 1 * summary statistics of the sample*****;

* include the codebook macros;
%include "C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\for macro\table_macro.sas";

ODS EXCEL file="C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\Table1-male.xlsx";
%TABLEN(DATA=tcgamale,
 BY=bctype,
 BYORDER=, 
 BYLABEL=, 
 SHOWTOTAL=1,
 VAR= age race ethnicity ajcc_pathologic_stage Event VAT IMAT SAT TAT TAT1 Muscle TSM1,
 TYPE=1 2 2 2 2 1 1 1 1 2 1 2)
ODS excel CLOSE;



data tcgamale;
set tcga;
where sex = "male";
RUN;


*****table 1 * summary statistics of the sample*****;

* include the codebook macros;
%include "C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\for macro\table_macro.sas";

ODS EXCEL file="C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\Table1-female.xlsx";
%TABLEN(DATA=tcgafemale,
 BY=bctype,
 BYORDER=, 
 BYLABEL=, 
 SHOWTOTAL=1,
 VAR= age race ethnicity ajcc_pathologic_stage Event VAT IMAT SAT TAT TAT1 Muscle TSM1,
 TYPE=1 2 2 2 2 1 1 1 1 2 1 2)
ODS excel CLOSE;

%TABLEN(data=tcga.tcga,
	by=bc_type,
	REFERENCE=H.M+H.A,
	var=followup, type=4, pvals=1,
 	surv_stat=Event, 
	cen_vl=0, 
 	survdisplay=events_n median hr)

%include "C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\for macro\mvmodels_web_20210718.sas";


ODS EXCEL file="C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\Tablesurvival-PREX.xlsx";
%mvmodels(DATA=tcga, METHOD=survival, TIME=followup, CENS=event, CEN_VL=0,
 COVARIATES=PREX1_grp ajcc_pathologic_stage sex race ethnicity Age, TYPE=2 2 2 2 2 1, CAT_DISPLAY=2, CONT_DISPLAY=3, CAT_REF= Low,
 CONT_STEP=10, BOLD_COV_LABEL=0, BY=bctype, SHADING=2, SHOWWALLS=0);
ODS excel CLOSE;


ODS EXCEL file="C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\Tablesurvival-female.xlsx";
 %mvmodels(DATA=tcgafemale, METHOD=survival, TIME=followup, CENS=event, CEN_VL=0,
 COVARIATES=bctypetwo ajcc_pathologic_stage race ethnicity Age, TYPE=2 2 2 2 1, CAT_DISPLAY=2, CONT_DISPLAY=3, CAT_REF= 1,
 CONT_STEP=10, BOLD_COV_LABEL=0, BY=, SHADING=2, SHOWWALLS=0);
ODS excel CLOSE;

 proc phreg data = tcga2;
where sex = "female";
class bctypetwo(ref="1")ajcc_pathologic_stage race ethnicity;*HM+HA DID NOT HAVE ANY DEATHS SO WE USE THE NEXT BEST SURVIVAL;
model followup*event(0) = bctypetwo ajcc_pathologic_stage race ethnicity Age /RISKLIMITS;
format tsm1 TSM. tat1 TAT. bctype bctype. event event.;
run; 




ODS EXCEL file="C:\Users\mahe22\OneDrive - The Ohio State University Wexner Medical Center\4. Kidney Cancer Project\! Updated Codes R and SAS\Tablesurvival-tatall.xlsx";
%mvmodels(DATA=tcga, METHOD=survival, TIME=followup, CENS=event, CEN_VL=0,
 COVARIATES=TSM1 ajcc_pathologic_stage sex race ethnicity Age TAT1, TYPE=2 2 2 2 2 1 2, CAT_DISPLAY=2, CONT_DISPLAY=3, CAT_REF= 2,
 CONT_STEP=10, BOLD_COV_LABEL=0, BY=, SHADING=2, SHOWWALLS=0);
ODS excel CLOSE;



***********************************************************************************************************************************************************************************;

proc phreg data = tcga.tcga;
class PREX1_grp(ref="Low") bctype ajcc_pathologic_stage sex race ethnicity;
model followup*event(0) = PREX1_grp bctype ajcc_pathologic_stage sex age race ethnicity PREX1_grp|bctype;
hazardratio 'Effect of body composition by Jak2_grp' PREX1_grp;
run;


proc phreg data = tcga2;
class sex (ref="female") bctypetwo ajcc_pathologic_stage race ethnicity;*HM+HA DID NOT HAVE ANY DEATHS SO WE USE THE NEXT BEST SURVIVAL;
model followup*event(0) = sex bctypetwo ajcc_pathologic_stage race ethnicity Age bctypetwo|sex /RISKLIMITS;
hazardratio 'Effect of body composition by Sex' sex;
format tsm1 TSM. tat1 TAT. bctypetwo bctype. event event.;
run; 



proc phreg data = tcga;
class sex (ref="male") bctype ajcc_pathologic_stage race ethnicity;*HM+HA DID NOT HAVE ANY DEATHS SO WE USE THE NEXT BEST SURVIVAL;
model followup*event(0) = sex bctype ajcc_pathologic_stage race ethnicity Age /RISKLIMITS;
hazardratio 'Effect of body composition by Sex' sex;
format tsm1 TSM. tat1 TAT. bctypetwo bctype. event event.;
run; 

proc freq data=tcgafemale;
table sex*bctype sex*event bctype*event;
run;
