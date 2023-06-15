clc; close all; clear all;
format short

%S.I. units

d2r=pi/180;

%tgt

V_T = 400;
X_T0 = 100;
Z_T0 = 20000;
l_T0 = -45*d2r;

%missile
X_M0 = 2000;
Z_M0 = 0;
l_M0 = 80*d2r;

%cntrl gains
Kdc = 1.1;
Ka = 4.5;
Ki = 14.3;
Kr = -0.37;
