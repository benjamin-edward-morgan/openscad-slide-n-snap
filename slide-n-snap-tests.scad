/*
This work is lincensed by Benjamin E Morgan under a Creative Commons Attribution 4.0 International License
http://creativecommons.org/licenses/by/4.0/

Original Source: https://github.com/benjamin-edward-morgan/slide-n-snap

These are test objects utilizing the slide-n-snap library. These test objects can be used to clibrate the 3D printer being used to print objects with slide-n-snap, to experiment with and fine-tune the parameters, or to test the strength of the connection between test parts.

Variables in the size profiles below are the same as those used in slide-n-snap.scad 


*/

include<slide-n-snap.scad>;

/**** Uncomment a size profile, the uncomment the ring_test_plate below ****/
//small
t=1.75;w=5.25;l=7;g=0.3;j=0.6;h=1;s=1;a=7;ring_inner_d=5;ring_bulk=2;

//medium
//t=2.0;w=6.5;l=8.5;g=0.35;j=0.7;h=1.2;s=1;a=8.5;ring_inner_d=5;ring_bulk=2;

//large
//t=2.75;w=8;l=10;g=0.4;j=0.8;h=2;s=1.5;a=10;ring_inner_d=5;ring_bulk=2;

/**** Uncoment to test ****/
ring_test_plate(t=t,w=w,l=l,g=g,j=j,h=h,s=s,a=a,ring_inner_d=ring_inner_d,ring_bulk=ring_bulk);

/*******************************/
/**slide-n-snap demonstrations**/
/*******************************/

/*
Test Plate to test tensile strength of assembly
*/
module ring_test_plate(t,w,l,g,j,h,s,a,ring_inner_d,ring_bulk) {
    slide_n_snap_female_clip_ring_test(t=t,w=w,l=l,g=g,j=j,h=h,s=s,a=a,ring_inner_d=ring_inner_d,ring_bulk=ring_bulk);  
    translate([l+ring_inner_d*2+ring_bulk,0,0])
    rotate(180)
    slide_n_snap_male_clip_ring_test(t=t,w=w,l=l,g=g,ring_inner_d=ring_inner_d);
}
   
/*
The slide_n_snap_female_clip_negative subtracted from a ring test part.
*/
//slide_n_snap_female_clip_ring_test(t=1.75,w=5.25,l=7,g=0.3,j=0.6,h=1,s=0.8,a=7,ring_inner_d=5,ring_bulk=2);
module slide_n_snap_female_clip_ring_test(t,w,l,g,j,h,s,a,ring_inner_d) {
    fml_len=slide_n_snap_female_length(w,t,g,j,h,l,s);
    fml_wid=slide_n_snap_channel_width(w,g);
    ring_r2=fml_wid/2+ring_bulk/2;
    ring_r1=ring_inner_d/2+ring_r2;
    ring_a = fml_wid+2*ring_bulk;
    ring_b = fml_len+2*ring_bulk;

    difference() {
        rotate([0,-90,0])
        ring(r1=ring_r1,r2=ring_r2,a=ring_a,b=ring_b);
    
        translate([0,fml_len/2,0])
        slide_n_snap_female_clip_negative(t=t,w=w,g=g,j=j,l=l,h=h,s=s,a=a,c=ring_r1);
    }
}

/*
The slide_n_snap_male_clip added with a ring test part.
*/
//slide_n_snap_male_clip_ring_test(t=1.75,w=5.25,l=7,g=0.3,ring_inner_d=5);
module slide_n_snap_male_clip_ring_test(t,w,l,g,ring_inner_d) {  
    ring_r2=l/2;
    ring_r1=ring_inner_d/2+ring_r2;
    
    translate([0,ring_r1+ring_r2,0])
    union() {        
        translate([0,0,ring_r2])
        rotate(-90)
        ring(r1=ring_r1,r2=ring_r2,a=ring_r2*2,b=w);
        
        slide_n_snap_male_clip(t=t,w=w,l=l);
    }
}

/*
A ring with a flat region on the exterior. major radius is r1, minor radius is r2. a is the width of the flat region and b is the length. To print flat, r2*2 must equal a.
*/
//ring(r1=4,r2=2,a=5,b=5);
module ring(r1,r2,a,b) {
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
          cube(center=true,size=[0.1,b,a]);
      }
      
      translate([r1+r2,0,0])
      rotate_extrude() 
      polygon(points=[
        [0,-a/2-10],
        [r1,-a/2-10],
        [r1,-sqrt(2)*r2],
        [r1-r2,-r2*tan(360/16)],
        [r1-r2,r2*tan(360/16)],
        [r1,sqrt(2)*r2],
        [r1,a/2+10],
        [0,a/2+10]
      ]);          
  }
}
