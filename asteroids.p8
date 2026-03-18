pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
intermission= true
duration = 120
cutscene = "idle"
launching = 0
launch = false  
round=0
cen_x=64
cen_y=75
--these are offsets------------
nose_x=0
nose_y=-7
left_x=-5
left_y=4
right_x=5
right_y=4
--thruster extension-----------
k=0.3
--timer------------------------
tick=0
timer=rnd(420)
-------------------------------
--ang---
a=0
thrust=0.008
fx = 0
fy = 0
vel_x=0
vel_y=0
drag = 0.97

------to test players hitbox--
test_pr=0
player_radius = 5
a_radius = 0
a_radius = 0
hit_pr = false
color_h=1 
--shooting--------------------
bullets={}
speed = 2
--now its time to construct rocks----
--spawn_asteroids()
hit = false
----time to spawn new asteroids-
level = 0
score=0
-----just for test-----------
--call_ufo()
ufo_hit = false
------------------------------
----call the ufo's laser------
laser={}
-----particles when something gets hit----
parts={}
ufo_parts={}
-----just for test too----------
--orbital_cannon()
ab_x=0
ab_y=0
ap_x=0
ap_y=0
ab_ab=0
proj=0
closest_x=0
closest_y=0
dis_x=0
dis_y=0
distance=0
detected=false
detect_color = 1
loading = 0
beam = {}
line_x=0
line_y=0
line_len=0
beam_dx=0--to calc dir of beam
beam_dy=0--to calc dir of beam
beam_col=8
bex=0 --for collsion on player
bey=0 --for collision on player
-----variables for slash ui----
slash_x=0
slash_o=0
par_col=1
scene = "menu"
blink_timer=0
text_x=30
text_y=90
highscore=000
end

function _update()
------will be state machine----
if scene == "menu" then
 update_menu() 
elseif scene == "game" then
--------of the game-----------

if intermission == true and scene == "game"
 then load_level(level)
 end
 
movement()
shoot()
acwb()
asteroid_rotation()
--update_asteroid_count()-------
asteroid_wrap()
move_asteroids()
check_level()
--i guess we makin ufos now-----
rotate_ufo()
wrap_ufo()
move_ufo()
ufo_hit_detection()
--for orbital cannon-----------
move_orbit()
check_orbit()
flash_orbit()
oc_fire()
move_beam()


the_ufo_parts()
------for ufo to shoot---------
tick+=1
if tick >= timer
then tick = 0
ufo_fires()
timer=rnd(420)
end
move_laser()
asteroid_parts()


for b in all(bullets) do
 b.d -= 1
 if b.d <= 0
  then del(bullets, b)
 end
 if b.x < 0
  then b.x = 128
 elseif b.x > 128
  then b.x = 0
 elseif b.y < 0
  then b.y = 128
 elseif b.y > 128 
  then b.y=0 
 end  
end  
--------------------------------
end 
end
 

function update_menu() 
 blink_timer += 1
 if blink_timer > 60 then
 blink_timer = 0
 end
 text_x += 1
 if text_x >= 128 
  then text_x = -20
 end 
 if btnp(❎) then
  scene="lobby"
 end

end


function draw_menu()
cls()
text="press ❎ to start"

if blink_timer < 50 then
print(text,text_x,text_y)
end
spr(0,0,0,16,16)

end


function draw_cut()

cls(3) 
movement()
---------draw ship--------------
line(lx, ly, nx, ny,7)
line(rx, ry, nx, ny,7)
line(lx, ly, rx, ry,7)

if cutscene == "idle" 
 then print("asteroids",44,10)
print("press ⬆️ to launch ",0,20)
print("but theres no going back...",0,30)
end

if btnp(⬆️) and launch == false then
 cutscene = "count"
 launch = true
end

if cutscene == "count" then 
 print("launching in ...",0,10) 
 launching+=1
 if launching<60 then
 print("3",70,10) 
 elseif launching < 120 then
 print("2",70,10) 
 elseif launching < 180 then
 print("1",70,10) 
 elseif launching >= 180
 then launching = 0
 cutscene = "blast"
 end
end

if cutscene == "blast" and launch == true then
 print("blastoff!",0,10) 
 cen_y -= 1
 line(ex,ey,tx,ty,9)
 if cen_y < -5 
 then scene = "start"
 end 
end  

end

function draw_start()
cls()
movement()
shoot()
---------draw ship--------------
line(lx, ly, nx, ny,7)
line(rx, ry, nx, ny,7)
line(lx, ly, rx, ry,7)

if btn(⬆️)  
then  line(ex,ey,tx,ty,9)
end
--------draw bullets-----------
for b in all(bullets) do
line(b.x,b.y,b.x,b.y)
end

for b in all(bullets) do
 b.d -= 1
 if b.d <= 0
  then del(bullets, b)
 end
 if b.x < 0
  then b.x = 128
 elseif b.x > 128
  then b.x = 0
 elseif b.y < 0
  then b.y = 128
 elseif b.y > 128 
  then b.y=0 
 end  
end  


launching+=1
if launching < 30 
 then cen_y -= 2
end  

print("high score: ",0,10)
print(highscore, 50,10)

print("press ➡️ when your ready",10,40)
print("to protect earth",10,50)

if btn(➡️) then
scene = "game"
end

end



function _draw()
if scene=="menu" then
 draw_menu()
elseif scene == "lobby"
 then draw_cut()
elseif  scene == "start"
 then draw_start()   
 elseif scene == "game" then 

cls()
---------draw ship--------------
line(lx, ly, nx, ny,7)
line(rx, ry, nx, ny,7)
line(lx, ly, rx, ry,7)

if btn(⬆️)
then  line(ex,ey,tx,ty,9)
end
--------draw bullets-----------
for b in all(bullets) do
line(b.x,b.y,b.x,b.y)
end
--------draw asteroids---------
for a in all(asteroids) do
for i=1,#rocks do
  p1=rocks[i]
  p2=rocks[i%#rocks+1]

  x1 = a.x + (a.s*p1.x*cos(a.r) - a.s*p1.y*sin(a.r))
  y1 = a.y + (a.s*p1.x*sin(a.r) + a.s*p1.y*cos(a.r))

  x2 = a.x + (a.s*p2.x*cos(a.r) - a.s*p2.y*sin(a.r))
  y2 = a.y + (a.s*p2.x*sin(a.r) + a.s*p2.y*cos(a.r))
  line(x1,y1,x2,y2,7)
end
end 
print(score,8)
--------display level up-------
print(level)

--------draw ufo---------------
for u in all(ufo) do
for i=1,#ship do 
				u1=ship[i]
				u2=ship[i%#ship+1]
				ux1 = u.x + (u1.x*cos(u.r)-u1.y*sin(u.r))*3
				uy1 = u.y + (u1.x*sin(u.r)+u1.y*cos(u.r))*3
				ux2 = u.x + (u2.x*cos(u.r)-u2.y*sin(u.r))*3
				uy2 = u.y + (u2.x*sin(u.r)+u2.y*cos(u.r))*3
				--this line is temporary--
				--will be replaced by--
				--ai movement function--
				
				----------------------------
				line(ux1,uy1,ux2,uy2,11)
end
end

--------laser of ufos----------
for l in all(laser) do
 line(l.x,l.y,l.x,l.y,8)
end
 
 
----particles boiiii-----------  
for p in all(parts) do
 line(p.x,p.y,p.x,p.y,par_col)
  --1
 end
  
----orbital cannon time-------
for o in all(oc) do
 line(o.x,o.y,o.sx,o.sy,o.dc)  
end

----draw orbital cannon beam---
for be in all(beam) do
 printh(be.c)
 circfill(be.x,be.y,8,beam_col)
end



--use a bool hit_pr
--but dont need it for testing
--as its a nuisance to check
 print("hit", 20, 20,color_h)
 


----time to put ui for level changes
if scene == "game" then
if (intermission==true and round <= duration-15) 
 then slash_x += 10
  
 rectfill(slash_o,50,slash_x,50+15,8)
 if slash_x >= 128
  then print("level" .. level+1,55,55,7)
  slash_o += 1.5
 end
end


if intermission==false
 then slash_x = 0
 slash_o = 0
 end
 
end 
--128
--50+15


-------particles for alien-----
--for p in all(parts)
for up in all(ufo_parts) do
 line(up.x,up.y,up.x,up.y,11)
  --1
 end
--end
		
end	
end	
				
-->8
------------player--------------
function movement()
--quick test to make sure rotation
--is correct

if scene == "game" or scene == "start" or scene == "start" then

if btn(⬇️)
 then a=(a+0.02)%1
 fx = nx - cen_x
 fy = ny - cen_y
end

end 
 
--find the backpoint of the ship

--now we finna add rotation---
--rotate the nose first--
nrx=nose_x*cos(a)-nose_y*sin(a)
nry=nose_x*sin(a)+nose_y*cos(a)
nx=cen_x+nrx
ny=cen_y+nry
--now rotate the left point---
lrx=left_x*cos(a)-left_y*sin(a)
lry=left_x*sin(a)+left_y*cos(a)
lx=cen_x+lrx
ly=cen_y+lry
--lastlt rotate the right------
rrx=right_x*cos(a)-right_y*sin(a)
rry=right_x*sin(a)+right_y*cos(a)
rx=cen_x+rrx
ry=cen_y+rry


--these will be our engine location
--for our thruster
ex = (lx+rx) / 2
ey = (ly+ry) / 2
bx = ex-nx
by = ey-ny
tx = ex + bx * k
ty = ey + by * k
tick+=1
if tick >= timer
 then tick = 0
 ty+=4
end 

if scene == "game" or scene == "start" or scene == "start" then
if btn(⬆️)
--ships forward direction
then fx = nx - cen_x
fy = ny - cen_y

--time to calc acc
vel_x += fx * thrust
vel_y += fy * thrust
end

vel_x *= drag
vel_y *= drag
--apply acc to ship----------
cen_x += vel_x
cen_y += vel_y 

--wrap ship to screen--------
if cen_x < 0
 then cen_x = 128
elseif cen_x > 128
 then cen_x = 0
end  
if cen_y < 0
 then cen_y = 128
elseif cen_y > 128
 then cen_y = 0
end

end 



-----test position to get radius--
for l in all(laser) do 
hx=l.x-cen_x
hy=l.y-cen_y
 if hx*hx+hy*hy < player_radius*player_radius
  then  --testing
  color_h+=1
 end  
end


----testing collision with asteroids
for a in all(asteroids) do
hax=(a.x-cen_x)
hay=(a.y-cen_y)
if a.s == 3
 then a_radius=10
elseif a.s == 2
 then a_radius=8
elseif a.s == 1
 then a_radius=5  
end 

total_radius=a_radius+player_radius
  
 if (hax*hax+hay*hay)<=total_radius*total_radius 
  then 
  color_h += 1
 end
 --elseif hax*hax+hay*hay<=player_radius*player_radius and a.s==2
end  

---this is for beam radius on player
for be in all(beam) do 
 bex=be.x-cen_x
 bey=be.y-cen_y
 if (bex*bex+bey*bey)<=(player_radius*8)
  then  
  color_h += 1
 end 
end  

end

-->8
---shooting-------
function shoot()
if btn(❎) and #bullets < 1 
then add(bullets,{x=nx,y=ny,speed=1,d=30}) 
end

for b in all(bullets) do
b.x+=speed*fx
b.y+=speed*fy
end

end
-->8
------------asteroids----------
function spawn_asteroids()
rocks={ {x=0,y=-6}, {x=5,y=-2}, {x=4,y=4}, {x=-3,y=5}, {x=-6,y=0}, {x=-4,y=-4} }
asteroids = {}
full=0
radius=0
test_r = 0
----find the radius of rock---- 
----for collision later--------
for r in all(rocks) do 
  test_r = ((r.x)^2 + (r.y)^2)
  if test_r > radius
   then radius = test_r
  end
end  
-------------------------------
repeat
repeat cx=rnd(128)
until cx<20 or cx>100
repeat cy=rnd(128)
until cy<40 or cy>80
rot=rnd(1)
rot_speed= rnd(0.01)-0.005
size = 3 
add(asteroids,{x=cx,y=cy,r=rot,rs=rot_speed,s=size})
full+=1
until full >= 8

end

----second function for infinite asteroids
function spawn_asteroids_2()
rocks={ {x=0,y=-6}, {x=5,y=-2}, {x=4,y=4}, {x=-3,y=5}, {x=-6,y=0}, {x=-4,y=-4} }
asteroids = {}
full=0
radius=0
test_r = 0
----find the radius of rock---- 
----for collision later--------
for r in all(rocks) do 
  test_r = ((r.x)^2 + (r.y)^2)
  if test_r > radius
   then radius = test_r
  end
end  
-------------------------------
repeat
repeat cx=rnd(128)
until cx<20 or cx>100
repeat cy=rnd(128)
until cy<40 or cy>80
rot=rnd(1)
rot_speed= rnd(0.01)-0.005
size = 3 
add(asteroids,{x=cx,y=cy,r=rot,rs=rot_speed,s=size})
full+=1
until full >= 20

end


---testing to see if i can add
---more asteroids without despawning
---the rest 

function more_asteroids()
 for i=1,12 do 
 repeat cx=rnd(128)
	until cx<20 or cx>100
	repeat cy=rnd(128)
	until cy<40 or cy>80
 add(asteroids,{x=cx,y=cy,r=rot,rs=rot_speed,s=size})
 end 
end 



function split_asteroid(x,y)
----take the center of previous--
--asteroid and make three small
--asteroids surrounding it-----
for i=1,2 do
add(asteroids,{x=x+rnd(60)-30,y=y+rnd(60)-30,r=rnd(1),rs=rnd(0.01)-0.002,s=2})
end 

end

function split_med_asteroid(x,y)
for i=1,3 do 
add(asteroids,{x=x+rnd(60)-30,y=y+rnd(60)-30,r=rnd(1),rs=rnd(0.01)-0.002,s=1})
end

end



function acwb()
  --collision asteroid to bullet--
for b in all(bullets) do
for a in all(asteroids) do
local hit_r = radius * 3
 if ((b.x-a.x)^2 + (b.y-a.y)^2) <= hit_r
  then del(bullets, b)
  del(asteroids,a)
  for i=1, 50 do
  add(parts,{x=a.x,y=a.y,sx=rnd(2)-1,sy=rnd(2)-1})
  end
  local ax = a.x
  local ay = a.y
  if a.s == 3
  then split_asteroid(ax,ay)
  score+=20
  elseif a.s == 2
  then split_med_asteroid(ax,ay)
  score+=50
  else score+=100
  end
  break
 end  

end
end 

end

function asteroid_rotation()
------asteroid rotation--------
for a in all(asteroids) do 
a.r += (a.rs%1)
end
-------------------------------
end

--update_asteroid_count()
--if full<=

function asteroid_wrap()
for a in all(asteroids) do 
 if a.x < 0 
  then a.x = 128
 elseif a.x > 128
  then a.x = 0
 end
 if a.y < 0
  then a.y = 128
 elseif a.y > 128
  then a.y = 0
 end 
end
end     

-------time to move asteroids--
function move_asteroids()
 for a in all(asteroids) do
  a.x+=rnd(0.1)-0.05
  a.y+=rnd(0.1)-0.05
  if level == 1
   then a.x+=rnd(0.1)-0.05
  a.y+=rnd(0.1)-0.05
  end
  
  if a.x < 40
  then a.x += rnd(0.09)
  elseif a.x > 80
  then a.x -= rnd(0.09)
  end
  if a.y < 20 
   then a.y += rnd(0.09)
  elseif a.y > 80 
   then a.y -= rnd(0.09)
  end    
 
 end

end

function asteroid_parts()
 ------particles-----------
for p in all(parts) do
 p.x+=p.sx
 p.y+=p.sy
 if p.x<0 or p.x>128 or p.y < 0 or p.y > 128
  then del(parts, p)
 end 
end 

end


-->8
-------level-------------------
function check_level()
 if intermission==false 
 then if level == 0 and score >= 5000
  then level+=1
  intermission = true
  round=0
  --load_level(level) 
 elseif level >= 1 and score >= 5000*(level+1)
  then level+=1
  intermission = true
  round=0
  --load_level(level)   
 end 
end   
end  

function load_level() 
if intermission == true 
then round += 1
if round >= duration 
 then intermission=false 
 round = 0 
 spawn_level(level)
end
end
end
 
  
function spawn_level(l)
 if l==0
  then spawn_asteroids()
  orbital_cannon()
  
  end 
 if l==1 --else
 	then more_asteroids()
 	call_ufo()
 	call_ufo()
 	orbital_cannon()
 	end
 if l==2 --else
  then more_asteroids()
		call_ufo()
		end   	
end
    
  
  
-->8
------------ufo's-------------
function call_ufo()
ufo ={}
ship = {{x=0,y=0},{x=2,y=1},{x=4,y=0},{x=2,y=-1}}
radius2=30
ufo_x=0
ufo_y=0
rotu=0
anglu=0
rotu_speed=0.004-rnd(0.002)
diru=0
if rnd(1) < 0.5 then
  diru = -1
else
  diru = 1
end


local wall=flr(rnd(5))
if wall==1 
then ufo_x=4
ufo_y = rnd(128)
elseif wall==2
then ufo_y = 128
ufo_x = rnd(128)
elseif wall==3
then ufo_x=128
ufo_y=rnd(128)
else ufo_y=0
ufo_x=rnd(128)
end

add(ufo,{x=ufo_x,y=ufo_y,r=rotu,rs=rotu_speed,r2=radius2,a=anglu,d=diru})
end


function rotate_ufo()
 for u in all(ufo) do
 u.r += (u.rs%.25)
 end
end 

function wrap_ufo()
 for u in all(ufo) do
  if u.x < 0
   then u.x = 128
  elseif u.x > 128
   then u.x = 0
  elseif u.y < 0
   then u.y = 128
  elseif u.y > 128
   then u.y = 0
  end
 end
end       
  
  
function move_ufo()

for u in all(ufo) do
 u.a += 0.005-rnd(0.0005)

 u.x = 64+cos(u.a*u.d)*u.r2*2 
 u.y = 64+sin(u.a*u.d)*u.r2*2

end

end  

------ufo needs to shoot player-
function ufo_fires()
 for u in all(ufo) do
  dx=cen_x-u.x
  dy=cen_y-u.y
  len = sqrt(dx*dx+dy*dy)
  add(laser,{x=u.x,y=u.y,dx=dx/len,dy=dy/len,speed=2.5})
 end
end


function move_laser() 
 for l in all(laser) do
 l.x += l.speed*l.dx
 l.y += l.speed*l.dy
 if l.y<0 or l.x<0 or l.x>128 or l.y>128
 then del(laser,l)
 end
 end


end

function ufo_hit_detection()
 for b in all(bullets) do
 for u in all(ufo) do
 --cant use radius for this one
 --bc radius handles its orbit
  local hit_r = 10
  if (b.x-u.x)^2+(b.y-u.y)^2 < hit_r*hit_r
    then 
    for i=1,50 do 
    add(ufo_parts,{x=u.x,y=u.y,sx=rnd(2)-1,sy=rnd(2)-1})
    end 
    del(ufo, u)
    del(bullet, b)
  end  
  end
  end 
  
  
  
  end 
  
  
function the_ufo_parts()
 --- have to make a new particles array 
 for up in all(ufo_parts) do
  up.x += up.sx
  up.y += up.sy 
  if up.x<0 or up.x>128 or up.y < 0 or up.y > 128
  then del(ufo_parts, up)
 end
 end

end  
-->8
------orbitical cannon----------
function orbital_cannon()
oc = {}

spot = 0
spawn = flr(rnd(4))+1 --up to 4
direc = flr(rnd(2))+1 --up to 2
---top spawn
if spawn == 1 and direc == 1 
 then ox = 64
 oy = 0
 spot_x = 0
 spot_y = 128
 move_x=rnd(1)
 move_y=0
 detect_color=1
 detect=false
 add(oc, {x=ox,y=oy,sx=spot_x,sy=spot_y,mx=move_x,my=move_y,dc=1,d=false,f=false})  
 
elseif spawn==1 and direc == 2
 then ox = 64
 oy = 0
 spot_x = 128
 spot_y = 128
 move_x=rnd(-1)
 move_y=0
 detect_color=1
 detect=false
 add(oc, {x=ox,y=oy,sx=spot_x,sy=spot_y,mx=move_x,my=move_y,dc=1,d=false,f=false})  
 
--right screen
elseif spawn == 2 and direc == 1
 then ox = 128
 oy = 64
 spot_x =0
 spot_y =0
 move_x=0
 move_y=rnd(1)
 detect_color=1
 detect=false
 add(oc, {x=ox,y=oy,sx=spot_x,sy=spot_y,mx=move_x,my=move_y,dc=1,d=false,f=false})  
 
elseif spawn == 2 and direc == 2
 then ox = 128
 oy = 64
 spot_x = 0
 spot_y = 128
 move_x = 0
 move_y = rnd(-1)
 detect_color=1
 detect=false
 add(oc, {x=ox,y=oy,sx=spot_x,sy=spot_y,mx=move_x,my=move_y,dc=1,d=false,f=false})  
 
--bottom screen
elseif spawn == 3 and direc == 1
 then ox=64
 oy = 128
 spot_x=0
 spot_y=0
 move_x = rnd(1)
 move_y = 0
 detect_color=1
 detect=false
 add(oc, {x=ox,y=oy,sx=spot_x,sy=spot_y,mx=move_x,my=move_y,dc=1,d=false,f=false})  
 
elseif spawn == 3 and direc == 2    
 then ox=64
 oy =128
 spot_x=128
 spot_y=0
 move_x=rnd(-1)
 move_y=0
 detect_color=1
 detect=false
 add(oc, {x=ox,y=oy,sx=spot_x,sy=spot_y,mx=move_x,my=move_y,dc=1,d=false,f=false})  
 
--left side  
elseif spawn==4 and direc==1
 then ox =0
 oy=64
 spot_x=128
 spot_y=0
 move_x=0
 move_y=rnd(1)
 detect_color=1
 detect=false
 add(oc, {x=ox,y=oy,sx=spot_x,sy=spot_y,mx=move_x,my=move_y,dc=1,d=false,f=false})  
 
elseif spawn == 4 and direc==2
 then ox=0
 oy=64
 spot_x=128
 spot_y=128
 move_x=0
 move_y=rnd(-1)
 detect_color=1
 detect=false
 add(oc, {x=ox,y=oy,sx=spot_x,sy=spot_y,mx=move_x,my=move_y,dc=1,d=false,f=false})  
 
end
fire = false

 
end 
 
function move_orbit()
for o in all(oc) do 
 if o.d == false
 then
 o.sx+=o.mx
 o.sy+=o.my
 if o.sx > 130 or o.sx < -20
  then del(oc, o)
 elseif o.sy > 140 or o.sy < -20
  then del(oc, o) 
 end
end
end
end  


---if laser alligns with player
function check_orbit()
  for o in all(oc) do
   ab_x=o.sx-o.x
   ab_y=o.sy-o.y
   ap_x=cen_x-o.x
   ap_y=cen_y-o.y
   ab_ab=((ab_x*ab_x)+(ab_y*ab_y))
   proj=((ab_x*ap_x)+(ab_y*ap_y))/ab_ab
   if proj < 0
    then proj = 0
   end 
   if proj > 1
    then proj = 1
   end
   closest_x=o.x+proj*(o.sx-o.x)
   closest_y=o.y+proj*(o.sy-o.y)
   dis_x=cen_x-closest_x
   dis_y=cen_y-closest_y
   distance=sqrt((dis_x)^2+(dis_y)^2)
   if distance <= player_radius
    then ----gonna replace this with beam
    o.d=true
   end   
  end
  
   
  for o in all(oc) do
  if o.d == true
  then o.dc=11
  end
  ---from here we will configure a laser
  ---to be continued 
  end  
end 

function flash_orbit() 
  for o in all(oc) do
  if o.d == true
  then loading+=1
  if loading%5 == 0
  then o.dc = 8
  end
  if loading >= 30
  then o.f=true
  loading=0
  end
  end 
  end
end

function oc_fire()
 for o in all(oc) do 
  if o.f == true
   then line_x=o.sx-o.x
   line_y=o.sy-o.y
   line_len=sqrt(line_x^2+line_y^2)
   beam_dx=line_x/line_len
   beam_dy=line_y/line_len
   add(beam,{x=o.x,y=o.y,dx=beam_dx,dy=beam_dy,s=2.5,c=8})
   del(oc,o)
   end
 end
 
end 

function move_beam()
 for be in all(beam) do
   be.x+= be.s*be.dx
   be.y+= be.s*be.dy
   if be.y<0 or be.y>128 or be.x<0 or be.x>128
    then del(be,b)
   end  
   end
end   


  
      
__gfx__
55555555555555571111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
55555555555555571111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
55555555555555571111111111111111111111111111111111119999999999111111111111111111111111111111111111111111111111111111111111111111
55555555555555571111111111111111111111111119999999999111111977777111111111111111111111111111111111111111111111111111111111111111
55555555555555571111111111119999999999999991111111111111119771117771111111111111111111111111111111111111111111111111111111111111
55555555555555771111111111119999999999999999999111111111197711111177711111111111111111111111111111111111111111111111111111111111
55555555555555711111111111119999999999111111111999999111977111111111177111111111111111111111111111111111111111111111111111111111
55555555555557711111111111111111119999999911111111111999771111111111117777111111111111111111111111111111111111111111111111111111
55555555555557111111111111111111111119991999999111111111777777777777777777711111111111111111111111111111111111111111111111111111
55555555555577111111111111111111111111119999119999999119711111111111117777111111111111111111111111111111111111111111111111111111
55555555557771111111111111111111111111111119999111119999711111111117771111111111111111111111111111111111111111111111111111111111
55555555577111111111111111111111111111111111119999911199771111117777111111111111111111111111111111111111111111111111111111111111
55555577711111111111111111111111111111111111111111999999971117777111111111111111111111111111111111111111111111111111111111111111
77777771111111111111111111111111111111111111111111111111977771111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555d551111111555555555555
5ccccddccccccddd55dddcccddcccdc55cccddccccccccdd55ccdddccccdd55ccdcccccccdd55cccccccdd55dddccccccdddcccc55cd551111115dddcccddccc
5ccddddcccccdddd55dddccddcccddc55ccdddcccccccddc55cddddcccddc55ccdcccccccdc55cccccdddd55dddccccdddddcccc55ccd55551115dddccddcccd
5cddddcccccddddc55ddccddccccccc55cddccccccccddcc55cddcccccdcc55cdd555555ddc55cccccdddc55ccccccddddcccccc55cccddd55115ddccddccccc
5cdddccccccdcccc55ccccd555555555555555cccd55555555ddc5555555555cdc575755ccc55cccddddcc55ccccddddcccc7ccd55cccccddd515ccccd555555
5cdcc5555555ccdd55ccccc555555555111115ccdd51111115ccc5557775555ddc555555ccc55ccddddccc55cccddddcccc7ccdd55cccccccdd55ccccc555575
5cccc5555555cddd55ccccc557555755111115cddd51111115ccc5577575555ccc555555cdd55dddddcccd55cccdddcccccccddc55ccccccccdd5ccccc555555
5cccd5575755dddd55cccdd555575555111115cddc51111115ccc5557575555cccccdcccddc55ddddcccdd55ccddccccccccddcc55cccccccccd5cccdd575555
5ccdd5575555dddc55ccddd555555555111115dddc51111115cdd5557775555ccccdccccdcc55ddc555cdc55555555cccc55555555cc5555cccd5ccddd555555
5cddd5577755ddcc55cdddccccccddc5111115cccc51111115cdd5555555555cccddcccddcc55ccc575dcc51111115cddd51111115cc5555cccd5cdddccccccd
5dddc5555555cccc55ddccccccccdcc5111115cccd51111115ddcccccdddc55cc555555555555ccc555ccc51111115ddcc51111115cc5555cccd5ddccccccccd
5ddcc5555555cccc55ddccccccdddcc5111115ccdd51111115dcccccddddc55cd511111111155ccc575ccc51111115cccc51111115cc5555cccd5ddccccccddd
5cccc5555555ccdd55ccccccccddccc5111115cddd51111115cccccddddcc55ddc51111111155ccd555ccc51111115c77c51111115cc7555cccd5ccccccccddc
5ccddccccddccddd55555555555cccc5111115dddc51111115cccccdddccc55ddcc5111111155cdd575ccd51111115cccd51111115cc7555cccd5555555555cc
5cdddcccdddcdddd55555777555cccd5111115cccc51111115ccc5555555555cccdd511111155dd0555cdd51111115ccdd51111115cc5555cccd5557555755cc
5ddddccddcccddcc55557757755ccdd5111115cccc51111115ccd5555557755cccddc51111155dcccccddd51111115cddd51111115cc5555cccd5557555755cc
5dddc5555555cccc55557555755dddd5111115cccc51111115cdd5577777555cccddcc5111155cccccdddd51111115cddc51111115cc5555cccd5557757755dd
5dccc5111115ccdd55557555755ddcc5111115ccdd51111115ddc5575555555ccc5cc0d511155ccccdddcc51111115ddcc51111115cc5555cccd5557777755dd
5cccc5111115cddd55555555555cccc5111115cddd51111115dcc5575555555ccc5ccdd551155ccddddccc51111115cccc51111115ccc55ccccd5555555555cc
5cddd5111115dddc55ddccddccccccd5111115dddc51111115ccc5577777755ccd55cddc51155cddddcccc55555555cccc55555555cccccccccd5ddccddccccc
5cddd5111115dccc55ddcdddcccccdd5111115ddcc51111115ccc5555555555cdd555ddcc5155ddddccccc55cddcccccddccdddc55cccccccccd5ddcdddccccc
5ddcc5111115cccc55dccddcccccddd5111115cccc51111115cddddcccc5d55cdd5555ccc5155dddccccdd55cdc7cccddcccdddc55ccccccccdd5dccddcccccd
5ddcc5111115cccd55ccdddccccdddc5111115cccc51111115cdddcccccdd55ddc5555ccdd555ccccccddd55dd7cccddccccddcc55ccccccddd55ccdddccccdd
5ccdd5111115cddd55ccddccccdddcc5111115ccdd51111115dddcccccddc55ddc55555cddc55cccccdddd55dcccddcccccddccc55cccccdd5515ccddccccddd
5dddd5111115dddd55ccdccccdddccc5111115cddd51111115ddcccccddcc55ccc555555dcc55cccccddcc55ccccdccccccdcccc55cccddd55115ccdccccdddc
5555551111155555555555555555555511111555555111111555555555555555555555555555555555555555555555555555555555ddd5555111555555555555
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111177111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111777111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111717111111111111111111111111711111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111177771111111717111111111111111111111111711111111111111111111111111111177777777111111111
11111111111111111111111111111111111111111171171111111717111111111111111111111111711111111111111111111111111777755555557711111111
11111111111111111111111111111111111111111771177111111717111111111111111111111111711111111111111111111117777555555555555577111111
11111111111111111111111111111111111111111771117111777777177111717711777117771111711111111111111111117775555555555555555555771111
11111111111111111111111111111111111111111771117717117771177111711711717177171111711111111111111111117555555555555555555555577111
11111111111111111111111111111111111111111771111777117771177111771777717171171111711111111111111111175555555555555555555555555711
11111111111111111111111111111111111111117171111771171171177111171177177171171111711111111111111117755555555555555555555555555577
11111111111111111111111111111111111111117171111771171177177111177117771171771117711111111111111775555555555555555555555555555555
11111111111111111111111111111111111111117171111771711717171111177171711177711777111111111111117755555555555555555555555555555555
11111111111111111111111111111111111111171171117777711717777111777771711177777711111111111111177555555555555555555555555555555555
11111111111111111111111111111111111111771177177177177711717777111111171771771111111111111111175555555555555555555555555555555555
11111111111111111111111111111111111111711117771117711111111111111111177711111111111111111111755555555555555555555555555555555555
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111117555555555555555555555555555555555555
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111177555555555555555555555555555555555555
__sfx__
0016000010650106500f6500f6500f6501065011650136501565017650186501965019650196501765015650156501565017650186501a6501b6501c6501d6501d6501d65033550325503255032550325502f550
001a00002625027250192501a2502625025250192501a2502625027250192501a25026250252501a250262502725019250192501a2502625025250192501a2502625027250192501a2502625025250192501a250
__music__
00 00424344
00 05424344

