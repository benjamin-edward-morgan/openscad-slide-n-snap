/*
This work is lincensed by Benjamin E Morgan under a Creative Commons Attribution 4.0 International License
http://creativecommons.org/licenses/by/4.0/
*/

include<slide-n-snap.scad>;

/*
These are test plates and demonstrations of how to use slide-n-snap.scad

Uncoment a profile, then a test below. These values were tested with PLA on a Makerbot Replicator 2
*/
//small
//t=1.75;w=5.25;l=7;g=0.3;j=0.6;h=1;s=0.8;a=7;ring_size=5;

//medium
//t=2.5;w=6.5;l=8.5;g=0.4;j=0.7;h=1.5;s=1;a=8.5;ring_size=5;

//large
//t=3.5;w=8;l=10;g=0.45;j=0.8;h=2;s=1.2;a=10;ring_size=5;

/*
Uncoment a test plate, assembly or cross section below
*/
//ring_test_plate(t=t,w=w,l=l,g=g,j=j,h=h,s=s,a=a,ring_size=ring_size);



/*******************************/
/**slide-n-snap demonstrations**/
/*******************************/

/*
Test Plate to test tensile strength of assembly
*/
module ring_test_plate(t,w,l,g,j,h,s,a,ring_size) {
    slide_n_snap_female_clip_ring_test(t=t,w=w,l=l,g=g,j=j,h=h,s=s,a=a,ring_size=ring_size);  
    translate([l+ring_size+w/2,l+ring_size/2,0])
    slide_n_snap_male_clip_ring_test(t=t,w=w,l=l,g=g,ring_size=ring_size);
}
   
/*
slide_n_snap_female_clip_negative differenced from a test piece. The ring is to help test the tensile strength of the connection.
*/
//slide_n_snap_female_clip_ring_test(t=1.75,w=5.25,l=7,g=0.3,j=0.6,h=1,s=0.8,a=7,ring_size=5);
module slide_n_snap_female_clip_ring_test(t,w,l,g,j,h,s,a,ring_size) {
    
    fml_len=slide_n_snap_female_length(w,t,g,j,h,l,s);
    fml_wid=slide_n_snap_channel_width(w,g);
    ringb = fml_len+4;
    ring_r2=fml_wid/2+1;
    ring_r1=ring_size/2+ring_r2;
    
    difference() {
        rotate([0,-90,0])
        ring(r1=ring_r1,r2=ring_r2,b=ringb);
    
        translate([0,fml_len/2,0])
        slide_n_snap_female_clip_negative(t=t,w=w,g=g,j=j,l=l,h=h,s=s,a=a,c=ring_r1);  
    }
}

/*
the slide_n_snap_male_clip unioned with a ring test piece. The ring is to help test the tensile strength of the connection.
*/
//slide_n_snap_male_clip_ring_test(t=1.75,w=5.25,l=7,g=0.3,ring_size=5);
module slide_n_snap_male_clip_ring_test(t,w,l,g,ring_size) {   
    union() {
        fml_wid=slide_n_snap_channel_width(w,g);
        ring_r2=l/2;
        ring_r1=ring_size/2+ring_r2;
        
        translate([0,0,ring_r2])
        rotate(-90)
        ring(r1=ring_r1,r2=ring_r2,b=w);
        
        slide_n_snap_male_clip(t=t,w=w,l=l);
    }
}

/*
a ring with a flat region on the exterior. major radius is r1, minor radius is r2. b is the width of the flat region. This part is used to make test pieces and is not a functional element of the slide_n_snap.
*/
//ring(r1=4,r2=2,b=5);
module ring(r1,r2,b) {
  difference() 
  { 
      hull() 
      {  
          translate([r1+r2,0,0])  
          rotate_extrude() 
          {  
              translate([r1,0,0])  
              rotate(360/16)    
              circle(r=r2/cos(360/16),$fn=8);   
          }

          translate([0.1/2,0,0])
          cube(center=true,size=[0.1,b,2*r2]);
      }
      
      translate([r1+r2,0,0])    
      rotate_extrude() 
      difference() 
      {  
          translate([0,-1.5*r2])  
          square(size=[r1,3*r2]);
              
          translate([r1,0,0])  
          rotate(360/16)    
          circle(r=r2/cos(360/16),$fn=8);   
      }
  }
}
