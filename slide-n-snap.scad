/*
This work is lincensed by Benjamin E Morgan under a Creative Commons Attribution 4.0 International License
http://creativecommons.org/licenses/by/4.0/

Use these openscad modules to attach two FDM printed parts rigidly together after printing with no additional hardware. Parts can be attached in such away that separating them is very difficult. Male and female parts should be printed in their given orientations to maximize the tensile strength of the connection. The two parts slide and snap together. A living spring and hook will snap and lock the pieces in place when they are assembled.

Usage: 
difference(){...} a slide_n_snap_female_clip_negative(...) from one part you wish to connect
 ~and~
union(){...} a slide_n_snap_male_clip(...) with the other you with to connect

t - width of smallest part of clip. larger value makes a stronger connection
w - width of largest part of clip. w > t+2*g
l - length of male clip part. l >= w
g - gap between faces inside the clip. decrease if assembly is loose, increase if the parts are too tight to assemble. This value depends on the tolerance of the 3D printer used.
j - gap around edge of living spring. generally this will be about 2*g or larger if the edge of the living spring prints fused together. This value depends on the tolerance of the 3D printer used.
h - length of the base of the hook. generally 1 or 2 mm is all that is needed when printing "right-side-up" for the hook to adhere to the print bed.
s - thickness of living spring. generally should be around 3 or 4 layers thick for fdm. In the "right-side-up" configuration, the living spring is formed with a bridge between the hook and the base of the channel. In the "upside-down" configuration, the living spring is formed directly on the print bed.
c - extra length of channel. This is how much extra channel to add in front of the clip. This length depends entirely on the placement of the female clip negative and the body it is removed from.
a - length of living spring. a <= l
epsilon - small value by which some values are fudged to overcome floating point errors. the default is 0.001 to make the real-time rendered view slightly less glitchy. All geometry will also work with an epsilon value of 0.
*/

/*******************************************/
/**Useful functions for using slide-n-snap**/
/*******************************************/
//overall height from xy plane to top of living spring. The part from which the female clip is cut must be at least this height.
function slide_n_snap_clip_height(t,w,s) = w/2-t/2+s;
//this is the total width of the inner channel along the x-axis at its widest point. The width of the part from which the female clip is cut should be significantly wider than this to be rigid. 
function slide_n_snap_channel_width(w,g) = g*(1+sqrt(2))*2+w;
//overall length of the entire female clip part, including the hook and gap in front of the living spring
function slide_n_snap_female_length(w,t,g,j,h,l,s) = w/2-t/2+s+h+g+j+l;

/*****************************/
/**Main slide-n-snap modules**/
/*****************************/
/*
positive space for the male clip. It should be printed in this orientation for maximum overall tensile strength when printed an FDM printer. This part taked advantage of the fact that FDM printed parts are generally more susceptible to break under strain in the z direction then in the x or y. The body of the part you wish to attatch this part too should be on the -y side of the zx plane.
*/
//slide_n_snap_male_clip(t=1.75,w=5.25,l=7);
module slide_n_snap_male_clip(t,w,l) {
    color("blue")
    linear_extrude(height=l)
    slide_n_snap_male_clip_profile(t=t,w=w);
}

/*
Negative space for the female clip. This includes the channel, living spring, and hook. It should be differenced() from the body of the part you with to attach. The body of your part should lie on top of the xy plane and be at least as tick as slide_n_snap_clip_height(...). If your part is siginficantly thicker, the cavity may lie entirely within the part, making the living spring very difficult to access. In the case, separating the two printed parts once assembled will be very difficult. 
*/
//slide_n_snap_female_clip_negative(t=1.75,w=5.25,g=0.25,j=0.5,l=7,h=1,s=0.8,a=7,c=20);
module slide_n_snap_female_clip_negative(t,w,g,j,l,h,s,a,c,epsilon=0.001,incl_cavity=true) {
    difference() 
    {
        union() {
            color("deeppink")
            translate([0,g,0])
            rotate([90,0,0])
            linear_extrude(height=l+g+w/2-t/2+s+h+c)
            slide_n_snap_clip_female_negative_profile(t=t,w=w,g=g,epsilon=epsilon);

            //this cube negative cuts out an area for the hook
            oprt = (1+sqrt(2));
            color("lightcoral")
            translate([
                -(w+2*g*oprt)/2,
                -w/2+t/2-s-h-g-l-j,
                -epsilon
            ]) 
            cube(size=[
                w+2*g*oprt,
                w/2-t/2+s+h+g+j,
                w/2-t/2+epsilon]
            );
        
            color("red")
            translate([0,0,w/2-t/2-epsilon])
            linear_extrude(height=s+2*epsilon)
            slide_n_snap_spring_negative_profile(t=t,w=w,g=g,j=j,l=l,s=s,h=h,a=a);    
    
            if(incl_cavity) {
                color("salmon")
                slide_n_snap_living_spring_cavity(t=t,w=w,g=g,j=j,l=l,s=s,h=h,a=a,epsilon=epsilon);
            }
        }
        
        color("hotpink")
        translate([0,-l-g,0])
        slide_n_snap_hook(t=t,w=w,g=g,j=j,h=h,s=s,epsilon=epsilon);
    }
}

/*
An upside down version of the female clip negative. It also assumes that the body is is differenced from lies above the xy plane. The thickness of the other body should be no more than lide_n_snap_clip_height(...) or should leave room for the male clip to be attached. The cavity is excluded in the case, since it lies entirely below the xy plane. 
*/
//slide_n_snap_upside_down_female_clip_negative(t=1.75,w=5.25,g=0.25,j=0.5,l=7,h=1,s=0.8,a=7,c=20);
module slide_n_snap_upside_down_female_clip_negative(t,w,g,j,l,h,s,a,c,epsilon=0.01) {
    
    translate([0,0,slide_n_snap_clip_height(t=t,w=w,s=s)])
    mirror([0,0,1])
    slide_n_snap_female_clip_negative(t=t,w=w,g=g,j=j,l=l,h=h,s=s,a=a,c=c,epsilon=epsilon,incl_cavity=false);
}

/******************************************************************/
/**Internal Modules used by the slide-n-snap parts are below here**/
/******************************************************************/
/*
the hook at the end of the living spring and locks the male clip part in place once assembled. The hook is angled on one side so that inserting the male clip part causes it to deflect upward. 
*/
//slide_n_snap_hook(t=2,w=5,g=0.25,j=0.5,h=0.5,s=0.8);
module slide_n_snap_hook(t,w,g,j,h,s,epsilon=0.001) {
    rotate([90,0,-90])
    linear_extrude(height=w+2*g*(1+sqrt(2))-2*j,center=true)
    polygon(points=[
        [0,-epsilon],
        [0,w/2-t/2+s+epsilon],
        [w/2-t/2+s+h+epsilon,w/2-t/2+s+epsilon],
        [h-epsilon,-epsilon]
    ]);
}

/*
this 2D profile removes 3 edges around the living spring, leaving 1 edge attached where the spring is connected to the rest of the body. Also leaves space for the hook.
*/
//slide_n_snap_spring_negative_profile(t=1.75,w=5.25,g=0.25,j=0.5,l=7,s=0.8,h=1,a=6);
module slide_n_snap_spring_negative_profile(t,w,g,j,l,s,h,a) {
    oprt = (1+sqrt(2));
    
    x1 = -w/2-g*oprt;
    x2 = x1+j;
    x3 = -x2;
    x4 = -x1;
    
    y1 = 0;
    y2 = w/2-t/2+s+2*g+h;
    y3 = a+w/2-t/2+s+h+2*g+j;
    
    translate([0,-y3-l+a+g])
    polygon(points=[
        [x1,y1],
        [x1,y3],
        [x2,y3],
        [x2,y2],
        [x3,y2],
        [x3,y3],
        [x4,y3],
        [x4,y1]
    ]);   
}

/*
box-shaped negative positioned over the living spring. This cavity leaves room over the living spring so it has room to move and enforces the thickness of the living spring when the slide_n_snap_female_clip_negative is removed from a thicker body
*/
//slide_n_snap_living_spring_cavity(t=1.75,w=5.25,g=0.25,j=0.5,l=7,s=0.8,h=1,a=6);
module slide_n_snap_living_spring_cavity(t,w,g,j,l,s,h,a,epsilon=0.0001) {
    y3 = a+w/2-t/2+s+h+2*g+j;   
    translate([
        -w/2-g*(1+sqrt(2)),
        -y3-l+a+g,
        slide_n_snap_clip_height(t,w,s)+epsilon
    ])
    cube(size=[
        slide_n_snap_channel_width(w,g),
        y3,
        w/2-t/2+g
    ]);   
}

/*
2D profile of negative space for the female clip part 
*/
//slide_n_snap_clip_female_negative_profile(t=1.75,w=5.25,g=0.25);
module slide_n_snap_clip_female_negative_profile(t,w,g,epsilon=0.001) {
   goprt = g*(1+sqrt(2));
   color("pink") 
   polygon(points=[
       [-w/2-goprt,w/2-t/2],
       [w/2+goprt,w/2-t/2],
       [t/2+goprt-epsilon,-epsilon],
       [-t/2-goprt+epsilon,-epsilon]
   ]);
}

/*
2D profile of male clip part
*/
//slide_n_snap_male_clip_profile(t=1.75,w=5.25);
module slide_n_snap_male_clip_profile(t,w) {
   color("blue") 
   polygon(points=[
       [t/2,0],[w/2,0],
       [w/2,-t/2],
       [0,-t/2],
       [-w/2,-t/2],
       [-w/2,0],[-t/2,0],
       [-w/2,w/2-t/2],
       [w/2,w/2-t/2]
    ]);
}