pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
cen_x=64
cen_y=57
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
--shooting--------------------
bullets={}
speed = 2
--now its time to construct rocks----
spawn_asteroids()
hit = false
----time to spawn new asteroids-
level = 0
score=0
-----just for test-----------
call_ufo()
------------------------------
----call the ufo's laser------
laser={}
-----particles when something gets hit----
parts={}
end

function _update()
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


------for ufo to shoot---------
tick+=1
if tick >= timer
then tick = 0
ufo_fires()
timer=rnd(420)
end
move_laser()

------particles-----------
for p in all(parts) do
 p.x+=p.sx
 p.y+=p.sy
 if p.x<0 or p.x>128 or p.y < 0 or p.y > 128
  then del(parts, p)
 end 
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


end 
 

function _draw()
cls()
---------draw ship--------------
line(lx, ly, nx, ny,7)
line(rx, ry, nx, ny,7)
line(lx, ly, rx, ry,7)
line(ex,ey,tx,ty,9)
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
 line(l.x,l.y,l.x,l.y,11)
end
 
 
----particles boiiii-----------  
for p in all(parts) do
 line(p.x,p.y,p.x,p.y,1)
  --1
 end
  

end
				
-->8
------------player--------------
function movement()
--quick test to make sure rotation
--is correct
if btn(⬇️)
 then a=(a+0.02)%1
 fx = nx - cen_x
 fy = ny - cen_y
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
until cx<40 or cx>70
repeat cy=rnd(128)
until cy<40 or cy>80
rot=rnd(1)
rot_speed= rnd(0.01)-0.005
size = 3 
add(asteroids,{x=cx,y=cy,r=rot,rs=rot_speed,s=size})
full+=1
until full >= 8

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
  a.x+=rnd(0.09)
  a.y+=rnd(0.09)
 
 end

end

function asteroid_parts()
 

end



-->8
-------level-------------------
function check_level()
 if level == 0 and score >= 5000
  then level+=1
 end 
 if level >= 1 and score >= score*(level+1)
  then level+=1
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

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
001a00001a250283502825028250282502825028250283502825028250192501a2501b2501c2501d2501e2501f250202502125022250232502425024250252502625027250282502825028250282501a2501a550
001a00002625027250192501a2502625025250192501a2502625027250192501a25026250252501a250262502725019250192501a2502625025250192501a2502625027250192501a2502625025250192501a250
__music__
00 00424344
00 01424344

